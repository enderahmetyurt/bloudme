module ApplicationHelper
  def locale_to_flag(locale)
    locales = {
      "en": "🇬🇧",
      "tr": "🇹🇷",
      "se": "🇸🇪"
    }

    locales[locale.to_sym]
  end
end
