using System;

namespace AdminPanel.Helpers
{
    public static class DataMasker
    {

        public static string MaskPhone(string phone)
        {
            if (string.IsNullOrEmpty(phone) || phone.Length < 10) return phone;
            return phone.Substring(0, 3) + " ***** " + phone.Substring(phone.Length - 2);
        }

        public static string MaskEmail(string email)
        {
            if (string.IsNullOrEmpty(email) || !email.Contains("@")) return email;

            var parts = email.Split('@');
            var name = parts[0];
            var domain = parts[1];

            if (name.Length <= 2) return email;

            var maskedName = name.Substring(0, 1) + new string('*', name.Length - 2) + name.Substring(name.Length - 1);
            return maskedName + "@" + domain;
        }

        public static string MaskSurname(string surname)
        {
            if (string.IsNullOrEmpty(surname) || surname.Length < 2) return surname;
            return surname.Substring(0, 1) + new string('*', 3);
        }

        public static string MaskFullName(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "";

            var parts = fullName.Trim().Split(' ');

            if (parts.Length < 2) return fullName;

            var surname = parts.Last();

            var names = string.Join(" ", parts.Take(parts.Length - 1));

            var maskedSurname = MaskSurname(surname);

            return $"{names} {maskedSurname}";
        }
    }
}