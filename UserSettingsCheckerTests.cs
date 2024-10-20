using System;
using NUnit.Framework;

namespace Zapper;

[TestFixture]
public class UserSettingsCheckerTests
{
    [Test]
    public void IsFeatureEnabled_ValidInputAllDisabled_ReturnsFalse()
    {
        Assert.That(UserSettingsChecker.IsFeatureEnabled("00000000", (int) UserSetting.Vouchers), Is.False);
    }

    [Test]
    public void IsFeatureEnabled_ValidInputSpecificEnabled_ReturnsTrue()
    {
        Assert.That(UserSettingsChecker.IsFeatureEnabled("00000010", (int) UserSetting.Vouchers), Is.True);
    }

    [Test]
    public void IsFeatureEnabled_ValidInputAllEnabled_ReturnsTrue()
    {
        Assert.That(UserSettingsChecker.IsFeatureEnabled("11111111", (int) UserSetting.Camera), Is.True);
    }

    [Test]
    public void IsFeatureEnabled_ValidInputEdgeCases_ReturnsExpectedResult()
    {
        Assert.That(UserSettingsChecker.IsFeatureEnabled("10000000", (int) UserSetting.SmsNotifications), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled("00000001", (int) UserSetting.Loyalty), Is.True);
    }

    [TestCase("")]
    [TestCase("0000000")]
    [TestCase("000000000")]
    public void IsFeatureEnabled_InvalidSettingsString_ThrowsArgumentException(string invalidSettings)
    {
        Assert.Throws<ArgumentException>(() => UserSettingsChecker.IsFeatureEnabled(invalidSettings, (int) UserSetting.SmsNotifications));
    }

    [Test]
    public void IsFeatureEnabled_NullSettingsString_ThrowsArgumentException()
    {
        Assert.Throws<ArgumentException>(() => UserSettingsChecker.IsFeatureEnabled(null, (int) UserSetting.SmsNotifications));
    }

    [Test]
    public void IsFeatureEnabled_AllSpecificSettings_ReturnsExpectedResults()
    {
        string settings = "10101010";
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.SmsNotifications), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.PushNotifications), Is.False);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Biometrics), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Camera), Is.False);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Location), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Nfc), Is.False);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Vouchers), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Loyalty), Is.False);
    }
    
    [Test]
    public void IsFeatureEnabled_AllSettings_ReturnsExpectedResults()
    {
        string settings = "11111111";
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.SmsNotifications), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.PushNotifications), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Biometrics), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Camera), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Location), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Nfc), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Vouchers), Is.True);
        Assert.That(UserSettingsChecker.IsFeatureEnabled(settings, (int) UserSetting.Loyalty), Is.True);
    }
}