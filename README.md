# Gemini Chatbot

Bu, akıllı ve sohbet tabanlı yanıtlar sağlamak için Google Gemini API'sini kullanan Flutter tabanlı bir chatbot uygulamasıdır. Uygulama, temiz bir kullanıcı arayüzü, sohbet geçmişi ve kullanıcıyı başlatmak için yönlendirici ipuçları içeren bir karşılama ekranı sunar.

## Ana Özellikler

-   **Sohbet Yapay Zekası:** Doğal ve akıllı konuşmalar için Google Gemini API'sini kullanır.
-   **Sohbet Geçmişi:** Konuşmalarınızı yerel olarak kaydederek istediğiniz zaman geri dönüp incelemenizi sağlar.
-   **Kullanıcı Dostu Arayüz:** Sohbet etmeyi kolay ve keyifli hale getiren temiz ve sezgisel bir tasarım.
-   **Karşılama Ekranı:** Sohbeti başlatmanıza yardımcı olacak örnek sorular içeren dostça bir karşılama ekranı.
-   **Yerel Depolama:** Verimli ve hızlı yerel veri depolama için Hive kullanır.

## Kullanılan Teknolojiler ve Paketler

-   **Flutter:** Mobil, web ve masaüstü için tek bir kod tabanından yerel olarak derlenmiş uygulamalar oluşturmak için kullanılan UI araç takımı.
-   **Google Gemini API:** Chatbot'un konuşma yeteneklerini güçlendiren yapay zeka modeli.
-   **Hive:** Yerel depolama için hafif ve hızlı bir anahtar-değer veritabanı.
-   **Google Fonts:** Güzel ve tutarlı tipografi için.
-   **Animated Text Kit:** Etkileyici metin animasyonları için.
-   **Path Provider:** Yerel veritabanına giden doğru yolu bulmak için.

 **API Anahtarını Ayarlayın**

    Bu projenin çalışması için bir Google Gemini API anahtarı gereklidir. Güvenlik nedeniyle, API anahtarınızı uygulamanızda doğrudan kodlamak yerine, ortam değişkenleri gibi güvenli bir şekilde saklamanız önemle tavsiye edilir.

    -   `lib/pages/chat_screen.dart` dosyasını açın.
    -   Aşağıdaki satırı bulun:

        ```dart
        static const apiKey = "YOUR_API_KEY";
        ```

    -   `"YOUR_API_KEY"` kısmını kendi Google Gemini API anahtarınızla değiştirin.

**Uygulamayı çalıştırın**

    ```sh
    flutter run
    ```

## Proje Yapısı

```
lib/
├── models/
│   ├── chat_session.dart
│   ├── message.dart
│   └── messages.dart
├── pages/
│   ├── chat_history_screen.dart
│   └── chat_screen.dart
├── services/
│   └── database_service.dart
├── utils/
│   ├── size.dart
│   └── style.dart
└── main.dart
```

-   **models:** `ChatSession` ve `Message` gibi uygulama için veri modellerini içerir.
-   **pages:** Sohbet ekranı ve sohbet geçmişi dahil olmak üzere uygulamanın kullanıcı arayüzü ekranlarını içerir.
-   **services:** Hive için `DatabaseService` gibi dış kaynaklarla etkileşim kuran servisleri içerir.
-   **utils:** `Size` ve `Style` gibi yardımcı sınıfları ve sabitleri içerir.
-   **main.dart:** Uygulamanın giriş noktasıdır.
