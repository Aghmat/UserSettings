public class UserSettingsChecker
{
    public static bool IsFeatureEnabled(string settings, int setting)
    {
        if (string.IsNullOrEmpty(settings) || settings.Length != 8)
        {
            throw new ArgumentException("Settings string must be exactly 8 characters long.");
        }

        if (setting < 1 || setting > 8)
        {
            throw new ArgumentException("Setting must be between 1 and 8.");
        }

        return settings[setting - 1] == '1';
    }
}