/*
* Copyright (c) 2022 Marco Betschart (https://marco.betschart.name)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marco Betschart <time-limit@marco.betschart.name
*/

public class Timer.MainWindow : Gtk.ApplicationWindow {

    public signal void schedule_notification (GLib.DateTime? datetime);
    private Timer.Widgets.Clock clock;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.marbetschar.time-limit",
            resizable: false,
            default_height: 200,
            default_width: 200
        );
    }

    construct {
        var header = new Gtk.HeaderBar () {
            width_request = 200
        };
        header.add_css_class ("titlebar");
        header.add_css_class (Granite.STYLE_CLASS_FLAT);
        header.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        set_titlebar (header);

        clock = new Timer.Widgets.Clock ();
        child = clock;

        var event_controller_key = new Gtk.EventControllerKey ();
        event_controller_key.key_released.connect ((keyval, keycode, state) => {
            switch (keyval) {
                case Gdk.Key.space:
                    clock.pause = !clock.pause;
                    if (clock.pause) {
                        schedule_notification (null);
                    } else {
                        schedule_notification (new GLib.DateTime.now_local ().add_seconds (clock.seconds));
                    }
                    break;

                case Gdk.Key.Escape:
                    clock.pause = false;
                    clock.seconds = 0;
                    schedule_notification (null);
                    break;
            }
        });        
        ((Gtk.Widget) this).add_controller (event_controller_key);
    }

    public void set_scheduled_notification_datetime (GLib.DateTime? datetime) {
        if (datetime == null) {
            clock.seconds = 0;

        } else {
            var now = new GLib.DateTime.now_local ();
            clock.seconds = datetime.difference (now) / 1000000;

            clock.pause = false;
            clock.start_ticking ();
        }
    }
}
