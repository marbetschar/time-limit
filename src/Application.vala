public class Timer : Gtk.Application {

    public Timer () {
        Object (
            application_id: "name.betschart.marco.timer",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this);
        main_window.default_height = 300;
        main_window.default_width = 300;
        main_window.title = "Timer";
        main_window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Timer ();
        return app.run (args);
    }
}
