/*
* Copyright (c) 2020 Marco Betschart (https://marco.betschart.name)
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
* Authored by: Marco Betschart <elementary-timer@marco.betschart.name
*/

public class Timer.Widgets.Clock : Gtk.Box {

    private Gtk.Label time_label;
    private Gtk.Label minutes_label;
    private Gtk.Label seconds_label;

    public Clock () {
        Object (orientation: Gtk.Orientation.VERTICAL, spacing: 12);
    }

    construct {
        var clock_provider = new Gtk.CssProvider ();
        clock_provider.load_from_resource ("name/betschart/marco/timer/Clock.css");

        time_label = new Gtk.Label ("16:49");
        var time_label_context = time_label.get_style_context ();
        time_label_context.add_class ("time-label");
        time_label_context.add_provider (clock_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        minutes_label = new Gtk.Label ("0'");
        var minutes_label_context = minutes_label.get_style_context ();
        minutes_label_context.add_class ("minutes-label");
        minutes_label_context.add_provider (clock_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        seconds_label = new Gtk.Label ("0\"");
        var seconds_label_context = seconds_label.get_style_context ();
        seconds_label_context.add_class ("seconds-label");
        seconds_label_context.add_provider (clock_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        add (time_label);
        add (minutes_label);
        add (seconds_label);
    }
}
