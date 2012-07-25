
#include "ox820.h"
#include "common.h"

#include "mtd-user.h"

int nandwrite_slc(char *image_path, int dev, loff_t mtdoffset,
	struct mtd_info_user *meminfo)
{
	int cnt = 0, ret;
	int image = -1;
	int imglen = 0, pagesize, blocksize;
	unsigned char *writebuf = NULL;
	int retCode = 0;

	if (lseek(dev, mtdoffset, SEEK_SET) != mtdoffset) {
		perror("lseek error");
		return -4;
	}

	if ((image = open(image_path, O_RDONLY)) < 0) {
		perror("open error");
		return -1;
	}

	imglen = lseek(image, 0, SEEK_END);
	lseek (image, 0, SEEK_SET);

	pagesize = meminfo->writesize;
	blocksize = meminfo->erasesize;

	// Allocate a buffer big enough to contain all the data for one page
	writebuf = (unsigned char*)MALLOC(pagesize);
	while (imglen > 0) {

		int tinycnt = 0;

		/* Check if we should skip this block */
		if (0 == (mtdoffset % blocksize)) {
			ret = nand_block_isbad(dev, mtdoffset);
			if (ret < 0) {
				retCode = -5;
				goto closeall;
			} else if (ret == 1) {
				if (!quiet)
					printf("Skip bad block at 0x%llx\n", mtdoffset);
				mtdoffset += blocksize;
				if (lseek(dev, mtdoffset, SEEK_SET) != mtdoffset) {
					perror("lseek error");
					retCode = -4;
					goto closeall;
				}
				continue;
			}
		}

		erase_buffer(writebuf, pagesize);
		/* Read up to one page data */
		while (tinycnt < pagesize) {
			cnt = read(image, writebuf + tinycnt, pagesize - tinycnt);
			if (cnt == 0) { /* EOF */
				break;
			} else if (cnt < 0) {
				perror ("File I/O error on input");
				retCode = -3;
				goto closeall;
			}
			tinycnt += cnt;
		}
		imglen -= tinycnt;

		if (write(dev, writebuf, pagesize) != pagesize) { 
			fprintf(stderr, "Unable to write data to 0x%llx\n", mtdoffset);
			retCode = -4;
			goto closeall;
		}
		mtdoffset += pagesize;
	}

closeall:
	if (writebuf) {
		free(writebuf);
	}

	close(image);

	if (imglen > 0)
	{
		fprintf(stderr, "Data was only partially written due to error\n");
	}

	return retCode;
}

