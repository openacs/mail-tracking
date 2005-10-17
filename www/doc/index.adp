<master>
<h3>The Idea</h3>
<p>mail tracking is an event driven, generic package to track outgoing emails
from acs-mail-lite.
</p>
<p>
As soon as an email was sent out and is deleted from the queue
mail-tracking creates a new record.
</p>
<p>
Two modes are available:
<ul>
<li><b>Tracking everything</b> - When the <code>TrackAllMails</code> parameter is set to 1
all outgoing mails are tracked.
<li><b>Tracking on package instance level</b> - If set to 0, a site-wide admin
can track single package instances. In order to do so the package id is
required.
</ul>
</p>
<p>
To track a package instance simple add the following link inside an admin tcl page
of your package:
<pre>
    set tracking_chunk [mail_tracking::display::request_widget \
        -object_id $package_id \
        -url [ad_conn url] \
    ]
</pre>
and this to the corresponding ADP page:
<pre>
    \@tracking_chunk;noquote\@
</pre>
</p>
<h3>Limitations</h3>
<p>
There are some limitations that a future package might fix:
<ul>
<li>Since not all emails are sent from acs-mail-lite we cannot track
everything.
<li>acs-mail-lite stores the email address of the sender. Thus the sender can
be an unregistered and therefore unknown user.
<li>Requesting tracking on the package instance level has no meaning if the
track all mails mode is active.
</ul>
</p>
