# Build X - تحديثات شاملة للتطبيق

## ملخص التحديثات

### 1. تغيير اسم التطبيق
- **الاسم الجديد**: Build X
- **الإصدار**: 1.0.0+1
- **التحديثات**:
  - `pubspec.yaml`: تم تغيير الاسم والوصف
  - `android/app/src/main/AndroidManifest.xml`: تم تحديث label التطبيق
  - `ios/Runner/Info.plist`: تم تحديث CFBundleDisplayName و CFBundleName

### 2. إزالة المزودات القديمة وإضافة SuperEmbed
- **تم حذف المزودات القديمة**:
  - AnimeWorldExtractor
  - AutoEmbedExtractor
  - HollyMovieExtractor
  - VidsrcExtractor
  - وجميع المزودات الأخرى

- **تم إضافة SuperEmbed**:
  - `SuperEmbedExtractor` جديد مع دعم VIP
  - يستخدم `multiembed.mov` API
  - دعم للأفلام والمسلسلات
  - دعم VIP player للجودة العالية

### 3. إضافة نظام القنوات التلفزيونية (IPTV)
- **النماذج الجديدة**:
  - `TvChannel` model مع جميع الخصائص المطلوبة
  
- **الخدمات**:
  - `IptvService` لجلب القنوات من iptv-org
  - دعم التخزين المؤقت
  - فلترة المحتوى غير المناسب (NSFW)
  
- **الواجهات**:
  - `TvChannelsScreen` لعرض القنوات
  - `TvChannelPlayerScreen` لتشغيل القنوات
  - `TvChannelCard` لعرض معلومات القناة
  
- **المميزات**:
  - بحث في القنوات
  - فلترة حسب البلد واللغة والفئة
  - تشغيل مباشر للقنوات

### 4. إضافة نظام الأنمي الكامل
- **النماذج الجديدة**:
  - `Anime` model مع جميع التفاصيل
  - `AnimeEpisode` model للحلقات
  
- **الخدمات**:
  - `AnimeService` محسن مع مزودات حقيقية
  - استخدام Jikan API للبيانات
  - استخدام Consumet API للروابط
  - روابط تجريبية للاختبار
  
- **الواجهات**:
  - `AnimeScreen` للصفحة الرئيسية للأنمي
  - `AnimeDetailsScreen` لتفاصيل الأنمي
  - `AnimePlayerScreen` لتشغيل الحلقات
  - `AnimeCard` لعرض الأنمي
  
- **المميزات**:
  - بحث في الأنمي
  - عرض الأنمي الشائع والموسمي
  - تفاصيل كاملة للأنمي
  - قائمة الحلقات
  - تشغيل الحلقات

### 5. تحديث الصفحة الرئيسية
- **إضافة تبويبات جديدة**:
  - Movies (الأفلام)
  - TV Shows (المسلسلات)
  - TV Channels (القنوات التلفزيونية) - جديد
  - Anime (الأنمي) - جديد
  - Favorites (المفضلة)
  - Settings (الإعدادات)

### 6. إضافة زر الضيف
- **في صفحة تسجيل الدخول**:
  - زر "Continue as Guest" بنفس التصميم
  - وظيفة `_continueAsGuest()` للدخول بدون تسجيل

### 7. التحسينات البرمجية
- **إصلاح الأخطاء البرمجية**:
  - تحديث جميع الاستيرادات
  - إصلاح نماذج البيانات
  - تحسين خدمات API
  
- **تحسين الأداء**:
  - إضافة timeout للطلبات
  - معالجة أفضل للأخطاء
  - logging محسن

## الملفات الجديدة المضافة

### النماذج (Models)
- `lib/models/anime.dart`
- `lib/models/tv_channel.dart`

### الخدمات (Services)
- `lib/services/anime_service.dart`
- `lib/services/iptv_service.dart`
- `lib/services/streams_extractor_service/extractors/superembed_extractor.dart`

### الشاشات (Screens)
- `lib/screens/anime_screen.dart`
- `lib/screens/anime_details_screen.dart`
- `lib/screens/anime_player_screen.dart`
- `lib/screens/tv_channels_screen.dart`
- `lib/screens/tv_channel_player_screen.dart`

### المكونات (Components)
- `lib/components/anime_card.dart`
- `lib/components/tv_channel_card.dart`

## الملفات المحدثة

### الملفات الأساسية
- `pubspec.yaml` - تحديث الاسم والإصدار
- `android/app/src/main/AndroidManifest.xml` - تحديث اسم التطبيق
- `ios/Runner/Info.plist` - تحديث اسم التطبيق

### الشاشات المحدثة
- `lib/screens/fragments_screen.dart` - إضافة تبويبات جديدة
- `lib/screens/landing_screen.dart` - إضافة زر الضيف

### الخدمات المحدثة
- `lib/services/streams_extractor_service/streams_extractor_service.dart` - استخدام SuperEmbed فقط

## APIs المستخدمة

### للأنمي
- **Jikan API**: `https://api.jikan.moe/v4` - للبيانات الأساسية
- **Consumet API**: `https://api.consumet.org/anime/gogoanime` - للروابط
- **Demo Videos**: Google Cloud Storage - للاختبار

### للقنوات التلفزيونية
- **IPTV-org**: `https://iptv-org.github.io/iptv/index.m3u` - قائمة القنوات

### للأفلام والمسلسلات
- **SuperEmbed**: `https://multiembed.mov` - المزود الجديد
- **TMDB API**: للبيانات الأساسية

## الحزم المطلوبة
جميع الحزم موجودة في `pubspec.yaml`:
- dio: للطلبات HTTP
- logger: للسجلات
- cached_network_image: للصور
- media_kit: لتشغيل الفيديو
- shared_preferences: للتخزين المحلي
- وجميع الحزم الأخرى المطلوبة

## حالة التطبيق
✅ **جاهز للاستخدام**
- جميع الميزات مُنفذة
- الأخطاء البرمجية مُصلحة
- اسم التطبيق محدث إلى "Build X"
- الإصدار 1.0.0+1
- نظام الأنمي يعمل مع مزودات حقيقية
- نظام القنوات التلفزيونية يعمل
- مزود SuperEmbed للأفلام والمسلسلات
- زر الضيف متاح

## ملاحظات مهمة
1. **الأنمي**: يستخدم APIs حقيقية مع روابط تجريبية للاختبار
2. **القنوات**: تعمل مع قنوات IPTV حقيقية
3. **الأفلام/المسلسلات**: تستخدم SuperEmbed كمزود وحيد
4. **التطبيق**: جاهز للبناء والنشر