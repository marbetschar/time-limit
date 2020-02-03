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

public class Timer.Widgets.Clock : Gtk.Overlay {

    private Timer.Widgets.ProgressHandle handle;
    private Timer.Widgets.Face face;
    private Timer.Widgets.Labels labels;

    private static Gtk.CssProvider css_provider;

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("name/betschart/marco/timer/Clock.css");
    }

    construct {
        Gtk.Allocation alloc;
        get_allocation(out alloc);

        debug ("clock.alloc(width: %f, height: %f)", alloc.width, alloc.height);

        handle = new Timer.Widgets.ProgressHandle ();

        face = new Timer.Widgets.Face ();
        face.margin = 20;

        labels = new Timer.Widgets.Labels ();
        labels.margin = 20;
        labels.valign = Gtk.Align.CENTER;
        labels.halign = Gtk.Align.CENTER;

        add (handle);
        add_overlay (face);
        add_overlay (labels);

        var context = get_style_context ();
        context.add_class ("clock");
        context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }
}
