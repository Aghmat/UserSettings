namespace Zapper;
using NUnit.Framework;

[TestFixture]
public class UserSettingsManagerTests
{
    private const string TestSettingsFilePath = "test_user_settings.dat";

    [TearDown]
    public void TearDown()
    {
        if (File.Exists(TestSettingsFilePath))
        {
            File.Delete(TestSettingsFilePath);
        }
    }

    [Test]
    public void WriteAndReadSettings_ValidInput_SuccessfullyStoresAndRetrievesSettings()
    {
        bool[] originalSettings = [true, false, true, true, false, false, true, false];
        UserSettingsManager.WriteSettings(originalSettings, TestSettingsFilePath);

        bool[] retrievedSettings = UserSettingsManager.ReadSettings(TestSettingsFilePath);

        Assert.That(retrievedSettings, Is.EqualTo(originalSettings));
    }

    [Test]
    public void WriteSettings_InvalidInput_ThrowsArgumentException()
    {
        bool[] invalidSettings = [true, false, true];
        Assert.Throws<ArgumentException>(() => UserSettingsManager.WriteSettings(invalidSettings, TestSettingsFilePath));
    }

    [Test]
    public void ReadSettings_FileNotFound_ThrowsFileNotFoundException()
    {
        Assert.Throws<FileNotFoundException>(() => UserSettingsManager.ReadSettings(TestSettingsFilePath));
    }

    [Test]
    public void IsFeatureEnabled_ValidSetting_ReturnsCorrectValue()
    {
        bool[] settings = [true, false, true, false, true, false, true, false];
        UserSettingsManager.WriteSettings(settings, TestSettingsFilePath);

        Assert.That(UserSettingsManager.IsFeatureEnabled(1, TestSettingsFilePath), Is.True);
        Assert.That(UserSettingsManager.IsFeatureEnabled(2, TestSettingsFilePath), Is.False);
        Assert.That(UserSettingsManager.IsFeatureEnabled(3, TestSettingsFilePath), Is.True);
        Assert.That(UserSettingsManager.IsFeatureEnabled(4, TestSettingsFilePath), Is.False);
        Assert.That(UserSettingsManager.IsFeatureEnabled(5, TestSettingsFilePath), Is.True);
        Assert.That(UserSettingsManager.IsFeatureEnabled(6, TestSettingsFilePath), Is.False);
        Assert.That(UserSettingsManager.IsFeatureEnabled(7, TestSettingsFilePath), Is.True);
        Assert.That(UserSettingsManager.IsFeatureEnabled(8, TestSettingsFilePath), Is.False);
    }

    [Test]
    public void IsFeatureEnabled_InvalidSetting_ThrowsArgumentException()
    {
        UserSettingsManager.WriteSettings(new bool[8], TestSettingsFilePath);
        Assert.Throws<ArgumentException>(() => UserSettingsManager.IsFeatureEnabled(0, TestSettingsFilePath));
        Assert.Throws<ArgumentException>(() => UserSettingsManager.IsFeatureEnabled(9, TestSettingsFilePath));
    }
}