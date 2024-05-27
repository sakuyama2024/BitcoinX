package org.alphacashcore.qt;

import android.os.Bundle;
import android.system.ErrnoException;
import android.system.Os;

import org.qtproject.qt5.android.bindings.QtActivity;

import java.io.File;

public class AlphacashQtActivity extends QtActivity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        final File alphacashDir = new File(getFilesDir().getAbsolutePath() + "/.alphacash");
        if (!alphacashDir.exists()) {
            alphacashDir.mkdir();
        }

        super.onCreate(savedInstanceState);
    }
}
