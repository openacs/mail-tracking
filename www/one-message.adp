<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<a href="@return_url;noquote@">#mail-tracking.Go_Back#</a>
<br><br>
<pre style="background-color: #eee; padding: .5em;">
#mail-tracking.Sender#:      @sender;noquote@
#mail-tracking.Recipient#:   @recipient;noquote@
#mail-tracking.Subject#:     @subject;noquote@
#mail-tracking.Attachments#: @download_files;noquote@</pre>

@body;noquote@

