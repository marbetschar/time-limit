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

public class Timer.Widgets.Labels : Gtk.Box {

    public Gtk.Stack time_stack;
    public Gtk.Label time_label;
    public Gtk.Image time_pause;
    public Gtk.Label minutes_label;
    public Gtk.Label seconds_label;

    private static Gtk.CssProvider css_provider;

    public Labels () {
        Object (orientation: Gtk.Orientation.VERTICAL, spacing: 0);
    }

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("com/github/marbetschar/time-limit/Labels.css");
    }

    construct {
        time_pause = new Gtk.Image.from_icon_name ("pause-symbolic");//, Gtk.IconSize.BUTTON);
        time_pause.add_css_class ("pause-icon");
        time_pause.get_style_context ().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        time_label = new Gtk.Label ("");
        time_label.add_css_class ("time-label");
        time_label.get_style_context ().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        time_stack = new Gtk.Stack () {
            hhomogeneous = false,
            valign = Gtk.Align.END,
            transition_type = Gtk.StackTransitionType.CROSSFADE
        };
        time_stack.add_child (time_label);
        time_stack.add_child (time_pause);

        minutes_label = new Gtk.Label ("") {
            margin_top = 0,
            margin_bottom = 0,
            margin_start = 0,
            margin_end = 0,
            valign = Gtk.Align.CENTER
        };
        minutes_label.add_css_class ("minutes-label");
        minutes_label.get_style_context ().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var minutes_label_attributes = new Pango.AttrList ();
        minutes_label_attributes.insert (Pango.attr_rise_new (-20000));
        minutes_label.attributes = minutes_label_attributes;

        seconds_label = new Gtk.Label ("") {
            valign = Gtk.Align.START
        };
        seconds_label.add_css_class ("seconds-label");
        seconds_label.get_style_context ().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        append (time_stack);
        append (minutes_label);
        append (seconds_label);
    }
}
