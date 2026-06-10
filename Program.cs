using System;
using System.Windows.Forms;
using Eventora.Forms;
using Eventora.Helpers;

namespace Eventora
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

          
            var connForm = new ConnectionForm();
            if (connForm.ShowDialog() != DialogResult.OK)
                return;

          
            Application.Run(new LoginForm());
        }
    }
}
