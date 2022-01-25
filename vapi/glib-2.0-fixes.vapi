namespace GLib {
    namespace Test {
        [CCode (cheader_filename = "glib-2.0/glib/gtestutils.h", cname = "g_test_get_root")]
        public static TestSuite get_root ();
    }
}