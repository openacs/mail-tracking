ad_library {

    Mail-Tracking

    Core procs for tracking mails. Important concepts:
    <ul>
    <li> tracking: each message sent out by acs-mail-lite is tracked - if it was queued.
    <li> intervals: as soon as the email was sent and removed from the queue.
    <li> participation: Either through registering a package instance or by setting the verbose parameter: TrackAllTraffic
    </ul>

    @creation-date 2005-05-31
    @author Nima Mazloumi <mazloumi@uni-mannheim.de>
    @cvs-id $Id$

}

namespace eval mail_tracking {

    ad_proc -public package_key {} {
        The package key
    } {
        return "mail-tracking"
    }
}