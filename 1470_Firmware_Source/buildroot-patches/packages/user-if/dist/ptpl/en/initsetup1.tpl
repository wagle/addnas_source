<p class="PageTitle">[% lang.m03015 %]</p>
<p>
[% lang.m03016 %]
</p>
<div style="border: 5px groove blue; padding=10px;background=lightgreen;">

[% INCLUDE EULA.txt %]

</div>
<form action="/auth/initsetup.pl" method="post">
<input type="submit" name="submit" tabindex="1" value="[% lang.m03018 %] >>" >
<input type="button" name="cancel" tabindex="2" value="[% lang.m03019 %]"  onClick="location='/home.pl'">
<input type="hidden" name="nextstage" value="2">
</form>
