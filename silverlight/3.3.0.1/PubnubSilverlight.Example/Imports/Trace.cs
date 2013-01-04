using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.IO.IsolatedStorage;
using System.IO;

namespace System.Diagnostics
{
    public class Trace
    {
        private static IsolatedStorageFile _storageFile = null;
        private static IsolatedStorageFileStream _storageFileStream = null;
        private static StreamWriter _streamWriter = null;

        public Trace()
        {
            _storageFile = IsolatedStorageFile.GetUserStoreForApplication();
            _storageFileStream = _storageFile.OpenFile("Trace.log", FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.ReadWrite);
            _streamWriter = new StreamWriter(_storageFileStream);
            _streamWriter.AutoFlush = true;
        }

        ~Trace()
        {
            _storageFileStream.Close();
        }

        public static void WriteLine(String message)
        {
            _streamWriter.WriteLine(message);
        }
    }
}
