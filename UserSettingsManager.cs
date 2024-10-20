namespace Zapper;

/*
 * Question 2.2 writes a single byte to a file
 */
public class UserSettingsManager
{
    public static void WriteSettings(bool[] settings, string path)
    {
        if (settings == null || settings.Length != 8)
        {
            throw new ArgumentException("Settings array must contain exactly 8 boolean values.");
        }

        byte settingsByte = 0;
        for (int i = 0; i < 8; i++)
        {
            if (settings[i])
            {
                settingsByte |= (byte)(1 << i);
            }
        }

        File.WriteAllBytes(path, [settingsByte]);
    }

    public static bool[] ReadSettings(string path)
    {
        if (!File.Exists(path))
        {
            throw new FileNotFoundException("Settings file not found.", path);
        }

        byte[] fileContent = File.ReadAllBytes(path);
        if (fileContent.Length != 1)
        {
            throw new InvalidDataException("Settings file has invalid content.");
        }

        byte settingsByte = fileContent[0];
        bool[] settings = new bool[8];
        for (int i = 0; i < 8; i++)
        {
            settings[i] = (settingsByte & (1 << i)) != 0;
        }

        return settings;
    }

    public static bool IsFeatureEnabled(int settingNumber, string path)
    {
        if (settingNumber < 1 || settingNumber > 8)
        {
            throw new ArgumentException("Setting number must be between 1 and 8.");
        }

        bool[] settings = ReadSettings(path);
        return settings[settingNumber - 1];
    }
}

