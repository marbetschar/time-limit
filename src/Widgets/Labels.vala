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

public class Timer.Widgets.Labels : Gtk.Box {

    private Gtk.Stack time_stack;
    private Gtk.Label time_label;
    private Gtk.Image time_pause;
    private Gtk.Label minutes_label;
    private Gtk.Label seconds_label;

    private static Gtk.CssProvider css_provider;

    public Labels () {
        Object (orientation: Gtk.Orientation.VERTICAL, spacing: 0);
    }

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("name/betschart/marco/timer/Labels.css");
    }

    construct {
        time_pause = new Gtk.Image.from_icon_name ("pause", Gtk.IconSize.BUTTON);

        time_label = new Gtk.Label ("16:49");
        var time_label_context = time_label.get_style_context ();
        time_label_context.add_class ("time-label");
        time_label_context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        time_stack = new Gtk.Stack ();
        time_stack.hhomogeneous = false;
        time_stack.valign = Gtk.Align.END;
        time_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        time_stack.add (time_label);
        time_stack.add (time_pause);

        minutes_label = new Gtk.Label ("0'");
        minutes_label.valign = Gtk.Align.CENTER;
        minutes_label.margin = 0;
        var minutes_label_context = minutes_label.get_style_context ();
        minutes_label_context.add_class ("minutes-label");
        minutes_label_context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        seconds_label = new Gtk.Label ("0\"");
        seconds_label.valign = Gtk.Align.START;
        var seconds_label_context = seconds_label.get_style_context ();
        seconds_label_context.add_class ("seconds-label");
        seconds_label_context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        pack_start (time_stack, true, false, 0);
        pack_start (minutes_label, true, false, 0);
        pack_start (seconds_label, true, false, 0);
    }
}
