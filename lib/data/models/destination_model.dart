import 'package:flutter/material.dart';

// MIGRATION PENDING — replaced by API after backend validation
// ------------------------------------------------------------------
// FIELD DATA COLLECTION
// GPS coordinates and destination information are gradually being
// replaced with researcher-collected primary data gathered through
// on-site visits across Biliran Province.
//
// Sambawan Island serves as the first validated destination in the
// BiliRoute tourism mobility database.
// ------------------------------------------------------------------

// ─────────────────────────────────────────────────────────────────────────────
// Destination Location (reusable, field-verification aware)
// ─────────────────────────────────────────────────────────────────────────────

class DestinationLocation {
  const DestinationLocation({
    required this.municipality,
    required this.province,
    required this.latitude,
    required this.longitude,
    this.isFieldVerified = false,
  });

  final String municipality;
  final String province;
  final double latitude;
  final double longitude;

  /// True when GPS was collected through on-site BiliRoute field survey.
  final bool isFieldVerified;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tour Package
// ─────────────────────────────────────────────────────────────────────────────

class TourPackage {
  const TourPackage({
    required this.name,
    required this.price,
    required this.duration,
    required this.inclusions,
    this.isPopular = false,
  });
  final String       name;
  final int          price;      // ₱ per person
  final String       duration;
  final List<String> inclusions;
  final bool         isPopular;

  factory TourPackage.fromJson(Map<String, dynamic> json) {
    return TourPackage(
      name: json['name'] as String? ?? '',
      price: (json['pricePerPerson'] as num?)?.toInt() ?? (json['price'] as num?)?.toInt() ?? 0,
      duration: json['duration'] as String? ?? '',
      inclusions: (json['inclusions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pricePerPerson': price,
      'duration': duration,
      'inclusions': inclusions,
      'isPopular': isPopular,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route Step
// ─────────────────────────────────────────────────────────────────────────────

class RouteStep {
  const RouteStep({
    required this.from,
    required this.to,
    required this.mode,
    required this.fare,
    required this.duration,
    required this.icon,
    this.isSeaRoute = false,
  });
  final String   from;
  final String   to;
  final String   mode;
  final int      fare;
  final String   duration;
  final IconData icon;
  final bool     isSeaRoute;
}

// ─────────────────────────────────────────────────────────────────────────────
// Recommended Route
// ─────────────────────────────────────────────────────────────────────────────

class RecommendedRoute {
  const RecommendedRoute({
    required this.label,
    required this.badge,
    required this.badgeColor,
    required this.totalFare,
    required this.totalDuration,
    required this.steps,
    this.isHighlighted = false,
  });
  final String          label;
  final String          badge;
  final Color           badgeColor;
  final int             totalFare;
  final String          totalDuration;
  final List<RouteStep> steps;
  final bool            isHighlighted;
}

// ─────────────────────────────────────────────────────────────────────────────
// Destination Item
// ─────────────────────────────────────────────────────────────────────────────

class DestinationItem {
  const DestinationItem({
    required this.id,
    required this.title,
    required this.location,
    required this.municipality,
    required this.province,
    required this.category,
    required this.rating,
    required this.imageAsset,
    required this.description,
    required this.categoryColor,
    required this.lat,
    required this.lng,
    this.isFieldVerified = false,
    required this.entranceFee,
    this.cottageFee,
    required this.envFee,
    required this.bestSeason,
    required this.difficulty,
    required this.difficultyColor,
    required this.travelTime,
    required this.estimatedFare,
    required this.signal,
    required this.thingsToDo,
    required this.whatToBring,
    required this.safetyReminders,
    required this.galleryAssets,
    required this.packages,
    required this.recommendedRoutes,
  });

  final String id;
  final String title;
  final String location;      // e.g. "Maripipi, Biliran Province"
  final String municipality;
  final String province;
  final String category;
  final double rating;
  final String imageAsset;
  final String description;
  final Color  categoryColor;
  // GPS coordinates
  // Sambawan Island: field-verified via BiliRoute on-site survey
  // All others: estimated — to be replaced with field data
  final double lat;
  final double lng;
  /// True when coordinates were collected during a BiliRoute field survey.
  final bool   isFieldVerified;
  // Fees
  final int    entranceFee;
  final int?   cottageFee;
  final int    envFee;
  // Travel info
  final String bestSeason;
  final String difficulty;
  final Color  difficultyColor;
  final String travelTime;
  final int    estimatedFare;
  final String signal;
  // Content lists
  final List<String>           thingsToDo;
  final List<String>           whatToBring;
  final List<String>           safetyReminders;
  final List<String>           galleryAssets;
  final List<TourPackage>      packages;
  final List<RecommendedRoute> recommendedRoutes;

  /// Consistent hero tag used across List → Details transition.
  String get heroTag => 'dest_$id';

  /// Returns a localized title based on active languageCode (e.g. 'es', 'fr', 'de', 'ja', 'ko').
  String localizedTitle(String languageCode) {
    switch (languageCode) {
      case 'es':
        switch (id.toLowerCase()) {
          case 'sambawan':     return 'Isla Sambawan';
          case 'tinago':        return 'Cascadas Tinago';
          case 'higatangan':   return 'Isla Higatangan';
          case 'ulan_ulan':
          case 'ulan-ulan':    return 'Cascadas Ulan-Ulan';
          case 'canaan':       return 'Granja Canaan Hill';
          case 'mainit':       return 'Aguas Termales Mainit';
          case 'tomalistalis': return 'Cascadas Tomalistalis';
          case 'iyusan':       return 'Terrazas de Arroz de Iyusan';
          case 'agta':         return 'Playa Agta';
          case 'recoletos':    return 'Cascadas Recoletos';
          case 'maripipi':     return 'Isla Maripipi';
          case 'cabilao':      return 'Isla Cabilao';
          default:             return title;
        }
      case 'fr':
        switch (id.toLowerCase()) {
          case 'sambawan':     return 'Île de Sambawan';
          case 'tinago':        return 'Chutes de Tinago';
          case 'higatangan':   return 'Île de Higatangan';
          case 'ulan_ulan':
          case 'ulan-ulan':    return 'Chutes de Ulan-Ulan';
          case 'canaan':       return 'Ferme Canaan Hill';
          case 'mainit':       return 'Sources Chaudes de Mainit';
          case 'tomalistalis': return 'Chutes de Tomalistalis';
          case 'iyusan':       return 'Rizières de Iyusan';
          case 'agta':         return 'Plage de Agta';
          case 'recoletos':    return 'Chutes de Recoletos';
          case 'maripipi':     return 'Île de Maripipi';
          case 'cabilao':      return 'Île de Cabilao';
          default:             return title;
        }
      case 'de':
        switch (id.toLowerCase()) {
          case 'sambawan':     return 'Insel Sambawan';
          case 'tinago':        return 'Tinago-Wasserfall';
          case 'higatangan':   return 'Insel Higatangan';
          case 'ulan_ulan':
          case 'ulan-ulan':    return 'Ulan-Ulan-Wasserfall';
          case 'canaan':       return 'Canaan Hill Farm';
          case 'mainit':       return 'Heiße Quellen Mainit';
          case 'tomalistalis': return 'Tomalistalis-Wasserfall';
          case 'iyusan':       return 'Reisterrassen von Iyusan';
          case 'agta':         return 'Strand Agta';
          case 'recoletos':    return 'Recoletos-Wasserfall';
          case 'maripipi':     return 'Insel Maripipi';
          case 'cabilao':      return 'Insel Cabilao';
          default:             return title;
        }
      case 'ja':
        switch (id.toLowerCase()) {
          case 'sambawan':     return 'サンバワン島';
          case 'tinago':        return 'ティナゴの滝';
          case 'higatangan':   return 'ヒガタンガン島';
          case 'ulan_ulan':
          case 'ulan-ulan':    return 'ウランウランの滝';
          case 'canaan':       return 'カナンヒル農園';
          case 'mainit':       return 'マイニット温泉';
          case 'tomalistalis': return 'トマリスタリスの滝';
          case 'iyusan':       return 'イユサン棚田';
          case 'agta':         return 'アグタビーチ';
          case 'recoletos':    return 'レコレトスの滝';
          case 'maripipi':     return 'マリピピ島';
          case 'cabilao':      return 'カビラオ島';
          default:             return title;
        }
      case 'ko':
        switch (id.toLowerCase()) {
          case 'sambawan':     return '삼바완 섬';
          case 'tinago':        return '티나고 폭포';
          case 'higatangan':   return '히가탕간 섬';
          case 'ulan_ulan':
          case 'ulan-ulan':    return '울란울란 폭포';
          case 'canaan':       return '가나안 힐 농장';
          case 'mainit':       return '마이닛 온천';
          case 'tomalistalis': return '토말리스타리스 폭포';
          case 'iyusan':       return '이유산 계단식 논';
          case 'agta':         return '악타 해변';
          case 'recoletos':    return '레콜레토스 폭포';
          case 'maripipi':     return '마리피피 섬';
          case 'cabilao':      return '카빌라오 섬';
          default:             return title;
        }
      case 'en':
      default:
        return title;
    }
  }

  /// Convenience accessor for map widgets.
  DestinationLocation get destinationLocation => DestinationLocation(
    municipality:    municipality,
    province:        province,
    latitude:        lat,
    longitude:       lng,
    isFieldVerified: isFieldVerified,
  );

  /// Factory constructor to parse MongoDB REST API JSON documents safely.
  factory DestinationItem.fromJson(Map<String, dynamic> json) {
    final locationMap = json['location'] as Map<String, dynamic>?;
    final geoJsonMap = json['geoJson'] as Map<String, dynamic>?;
    final coordinates = geoJsonMap?['coordinates'] as List?;

    // CRITICAL: MongoDB GeoJSON coordinates are [longitude, latitude]
    final double lng = (coordinates != null && coordinates.isNotEmpty)
        ? (coordinates[0] as num).toDouble()
        : (json['lng'] as num?)?.toDouble() ?? 0.0;
    final double lat = (coordinates != null && coordinates.length > 1)
        ? (coordinates[1] as num).toDouble()
        : (json['lat'] as num?)?.toDouble() ?? 0.0;

    final feesMap = json['fees'] as Map<String, dynamic>?;
    final travelInfoMap = json['travelInfo'] as Map<String, dynamic>?;
    final contentMap = json['content'] as Map<String, dynamic>?;
    final galleryList = json['gallery'] as List?;

    List<String> galleryUrls = [];
    String coverUrl = 'assets/images/sambawan.jpg';

    if (galleryList != null && galleryList.isNotEmpty) {
      for (final item in galleryList) {
        if (item is Map<String, dynamic> && item['url'] != null) {
          final url = item['url'] as String;
          galleryUrls.add(url);
          if (item['isPrimary'] == true) {
            coverUrl = url;
          }
        }
      }
      if (coverUrl == 'assets/images/sambawan.jpg' && galleryUrls.isNotEmpty) {
        coverUrl = galleryUrls.first;
      }
    }

    final categoryStr = json['category'] as String? ?? 'Island';
    final difficultyStr = travelInfoMap?['difficulty'] as String? ?? 'Moderate';

    return DestinationItem(
      id: json['slug'] as String? ?? json['_id'] as String? ?? '',
      title: json['name'] as String? ?? json['title'] as String? ?? '',
      location: '${locationMap?['municipality'] ?? json['municipality'] ?? ''}, ${locationMap?['province'] ?? json['province'] ?? 'Biliran Province'}',
      municipality: locationMap?['municipality'] as String? ?? json['municipality'] as String? ?? '',
      province: locationMap?['province'] as String? ?? json['province'] as String? ?? 'Biliran Province',
      category: categoryStr,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      imageAsset: coverUrl,
      description: json['description'] as String? ?? '',
      categoryColor: _resolveCategoryColor(categoryStr),
      lat: lat,
      lng: lng,
      isFieldVerified: json['isFieldVerified'] as bool? ?? false,
      entranceFee: (feesMap?['entrance'] as num?)?.toInt() ?? (json['entranceFee'] as num?)?.toInt() ?? 0,
      cottageFee: (feesMap?['cottage'] as num?)?.toInt() ?? (json['cottageFee'] as num?)?.toInt(),
      envFee: (feesMap?['environmental'] as num?)?.toInt() ?? (json['envFee'] as num?)?.toInt() ?? 0,
      bestSeason: travelInfoMap?['bestVisitingSeason'] as String? ?? json['bestSeason'] as String? ?? '',
      difficulty: difficultyStr,
      difficultyColor: _resolveDifficultyColor(difficultyStr),
      travelTime: travelInfoMap?['estimatedTravelTimeFromNaval'] as String? ?? json['travelTime'] as String? ?? '',
      estimatedFare: (travelInfoMap?['estimatedFareFromNaval'] as num?)?.toInt() ?? (json['estimatedFare'] as num?)?.toInt() ?? 0,
      signal: travelInfoMap?['mobileSignal'] as String? ?? json['signal'] as String? ?? '',
      thingsToDo: (contentMap?['thingsToDo'] as List?)?.map((e) => e.toString()).toList() ??
          (json['thingsToDo'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      whatToBring: (contentMap?['whatToBring'] as List?)?.map((e) => e.toString()).toList() ??
          (json['whatToBring'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      safetyReminders: (contentMap?['safetyReminders'] as List?)?.map((e) => e.toString()).toList() ??
          (json['safetyReminders'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      galleryAssets: galleryUrls.isNotEmpty
          ? galleryUrls
          : (json['galleryAssets'] as List?)?.map((e) => e.toString()).toList() ?? [],
      packages: (json['packages'] as List?)
              ?.map((e) => TourPackage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendedRoutes: const [],
    );
  }

  static Color _resolveCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'island':
        return const Color(0xFF14B8A6);
      case 'beach':
        return const Color(0xFF3B82F6);
      case 'falls':
      case 'waterfall':
        return const Color(0xFF06B6D4);
      case 'forest':
      case 'mountain':
        return const Color(0xFF10B981);
      case 'historical':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  static Color _resolveDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'moderate':
        return const Color(0xFFF59E0B);
      case 'difficult':
      case 'extreme':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// All Biliran Destinations (mock dataset — scalable for API integration)
// ─────────────────────────────────────────────────────────────────────────────

const allBiliranDestinations = <DestinationItem>[

  // ── Sambawan Island — FIELD VERIFIED ✅ ────────────────────────────────────
  // Source: BiliRoute Research Team on-site GPS survey
  // Coordinates: Primary data collected at Sambawan Island landing area
  DestinationItem(
    id:              'sambawan_island',
    title:           'Sambawan Island',
    location:        'Maripipi, Biliran Province',
    municipality:    'Maripipi',
    province:        'Biliran Province',
    category:        'Island',
    rating:          4.9,
    imageAsset:      'assets/images/sambawan.jpg',
    isFieldVerified: true,
    description:
        'A breathtaking sandbar paradise with powdery white sand and crystal-clear turquoise '
        'waters. Sambawan Island is consistently ranked among the top island destinations in '
        'Eastern Visayas, featuring a dramatic elongated sandbar that becomes a floating island '
        'strip at high tide — a magical sight that draws tourists year-round.',
    categoryColor:   Color(0xFF14B8A6),
    // Field-verified GPS — BiliRoute on-site survey
    lat:             11.766384941701004,
    lng:             124.26429026111757,
    entranceFee:     80,
    cottageFee:      300,
    envFee:          20,
    bestSeason:      'March – June',
    difficulty:      'Easy',
    difficultyColor: Color(0xFF10B981),
    travelTime:      '2–3 hrs from Naval',
    estimatedFare:   1110,
    signal:          'None',
    thingsToDo: [
      'Snorkeling & swimming in crystal waters',
      'Sandbar island hopping tour',
      'Underwater photography',
      'Sunset watching from the sandbar',
      'Beach volleyball & shore games',
      'Fish feeding at the reef',
    ],
    whatToBring: [
      'Reef-safe sunscreen (SPF 50+)',
      'Waterproof dry bag & phone case',
      'Cash only (no ATM on island)',
      'Extra set of clothes',
      'Snorkeling gear (rentable on-site)',
      'Drinking water & light snacks',
    ],
    safetyReminders: [
      'Book boat in advance — weather cancellations are common',
      'Wear life vest during all sea crossings',
      'No overnight camping without LGU permit',
      'Inform the Maripipi Tourism Office before travel',
      'Do not remove coral or marine life — protected area',
    ],
    galleryAssets: [
      'assets/images/sambawan.jpg',
      'assets/images/higatangan.jpg',
      'assets/images/maripipi.jpg',
      'assets/images/dalutan.jpg',
    ],
    packages: [
      TourPackage(
        name:       'Sambawan Day Tour',
        price:      800,
        duration:   '8–10 hours',
        inclusions: ['Boat charter (shared)', 'Local guide', 'Environmental fee'],
        isPopular:  true,
      ),
      TourPackage(
        name:       '3-Island Hopping',
        price:      1200,
        duration:   'Full day',
        inclusions: ['Sambawan + 2 islands', 'Boat', 'Snorkeling gear'],
      ),
      TourPackage(
        name:       'Overnight Sandbar Camp',
        price:      1800,
        duration:   '2 days / 1 night',
        inclusions: ['Tent rental', 'Boat (round trip)', 'Bonfire kit', 'Breakfast'],
      ),
    ],
    recommendedRoutes: [
      RecommendedRoute(
        label:         'Best Route',
        badge:         '⭐ Recommended',
        badgeColor:    Color(0xFF1E3A8A),
        totalFare:     1110,
        totalDuration: '2 hrs 40 min',
        isHighlighted: true,
        steps: [
          RouteStep(from: 'Tacloban Airport', to: 'Naval Terminal',    mode: 'Van / Bus',    fare: 120,  duration: '2 hrs',    icon: Icons.directions_bus_rounded),
          RouteStep(from: 'Naval',            to: 'Kawayan Port',      mode: 'Multicab',     fare: 55,   duration: '45 min',   icon: Icons.airport_shuttle_rounded),
          RouteStep(from: 'Kawayan Port',     to: 'Sambawan Island',   mode: 'Boat Charter', fare: 800,  duration: '30 min',   icon: Icons.sailing_rounded, isSeaRoute: true),
        ],
      ),
      RecommendedRoute(
        label:         'Budget Route',
        badge:         '💰 Cheapest',
        badgeColor:    Color(0xFF059669),
        totalFare:     615,
        totalDuration: '3 hrs 30 min',
        steps: [
          RouteStep(from: 'Tacloban',     to: 'Naval',        mode: 'Shared Van',  fare: 80,  duration: '2.5 hrs', icon: Icons.directions_car_rounded),
          RouteStep(from: 'Naval',        to: 'Kawayan',      mode: 'Multicab',    fare: 55,  duration: '45 min',  icon: Icons.airport_shuttle_rounded),
          RouteStep(from: 'Kawayan',      to: 'Sambawan Port',mode: 'Habal-habal', fare: 60,  duration: '25 min',  icon: Icons.motorcycle_rounded),
          RouteStep(from: 'Port',         to: 'Sambawan',     mode: 'Shared Boat', fare: 420, duration: '30 min',  icon: Icons.sailing_rounded, isSeaRoute: true),
        ],
      ),
      RecommendedRoute(
        label:         'Express Route',
        badge:         '⚡ Fastest',
        badgeColor:    Color(0xFFF59E0B),
        totalFare:     2720,
        totalDuration: '1 hr 40 min',
        steps: [
          RouteStep(from: 'Tacloban Airport', to: 'Naval Port',       mode: 'Private Van',    fare: 600,  duration: '1.5 hrs', icon: Icons.local_taxi_rounded),
          RouteStep(from: 'Naval Port',       to: 'Sambawan Island',  mode: 'Direct Charter', fare: 2000, duration: '50 min',  icon: Icons.sailing_rounded, isSeaRoute: true),
        ],
      ),
    ],
  ),

  // ── Agta Beach ──────────────────────────────────────────────────────────────
  // Coordinates: Estimated — pending field survey
  DestinationItem(
    id:            'agta_beach',
    title:         'Agta Beach',
    location:      'Almeria, Biliran Province',
    municipality:  'Almeria',
    province:      'Biliran Province',
    category:      'Beach',
    rating:        4.7,
    imageAsset:    'assets/images/agta.JPG',
    description:
        'A pristine stretch of white sand framed by lush mountain backdrops and gentle sea '
        'breezes. Agta Beach in Almeria is one of Biliran\'s most accessible beach destinations, '
        'beloved for its calm shallow waters ideal for families. Features local cottage rentals, '
        'seafood stalls, and stunning sunset views of nearby islands.',
    categoryColor:   Color(0xFF3B82F6),
    lat:             11.8122,
    lng:             124.3893,
    entranceFee:     30,
    cottageFee:      200,
    envFee:          10,
    bestSeason:      'November – May',
    difficulty:      'Easy',
    difficultyColor: Color(0xFF10B981),
    travelTime:      '45 min from Naval',
    estimatedFare:   220,
    signal:          'Strong',
    thingsToDo: [
      'Swimming & beach relaxation',
      'Sunset & island photography',
      'Kayaking (rental available)',
      'Fresh seafood dining by the shore',
      'Beach games & bonfire',
    ],
    whatToBring: [
      'Sunscreen & after-sun lotion',
      'Swimwear & towel',
      'Cash for food & cottage',
      'Camera or waterproof phone case',
      'Portable speaker (optional)',
    ],
    safetyReminders: [
      'Swim only in designated safe zones',
      'Watch for strong currents during peak tide',
      'Keep the beach clean — ₱500 fine for littering',
      'Do not leave valuables unattended on the shore',
    ],
    galleryAssets: [
      'assets/images/agta.JPG',
      'assets/images/sambawan.jpg',
      'assets/images/dalutan.jpg',
      'assets/images/higatangan.jpg',
    ],
    packages: [
      TourPackage(
        name:       'Beach Day Package',
        price:      350,
        duration:   '6–8 hours',
        inclusions: ['Cottage rental', 'Beach entrance', 'Kayak (1 hr)'],
        isPopular:  true,
      ),
      TourPackage(
        name:       'Sunset Seafood',
        price:      650,
        duration:   'Afternoon – Evening',
        inclusions: ['Cottage', 'Seafood platter for 2', 'Drinks'],
      ),
    ],
    recommendedRoutes: [
      RecommendedRoute(
        label:         'Best Route',
        badge:         '⭐ Recommended',
        badgeColor:    Color(0xFF1E3A8A),
        totalFare:     220,
        totalDuration: '45 min',
        isHighlighted: true,
        steps: [
          RouteStep(from: 'Naval Terminal', to: 'Almeria', mode: 'Multicab', fare: 80, duration: '30 min', icon: Icons.airport_shuttle_rounded),
          RouteStep(from: 'Almeria',        to: 'Agta Beach', mode: 'Tricycle', fare: 30, duration: '10 min', icon: Icons.electric_rickshaw_rounded),
        ],
      ),
      RecommendedRoute(
        label:         'Budget Route',
        badge:         '💰 Cheapest',
        badgeColor:    Color(0xFF059669),
        totalFare:     110,
        totalDuration: '50 min',
        steps: [
          RouteStep(from: 'Naval', to: 'Almeria',    mode: 'Multicab',   fare: 80, duration: '30 min', icon: Icons.airport_shuttle_rounded),
          RouteStep(from: 'Almeria', to: 'Agta Beach', mode: 'Walk/Habal', fare: 20, duration: '15 min', icon: Icons.directions_walk_rounded),
        ],
      ),
    ],
  ),

  // ── Kasabangan Falls ─────────────────────────────────────────────────────────
  // Coordinates: Estimated — pending field survey
  DestinationItem(
    id:            'kasabangan',
    title:         'Kasabangan Falls',
    location:      'Caibiran, Biliran Province',
    municipality:  'Caibiran',
    province:      'Biliran Province',
    category:      'Waterfall',
    rating:        4.8,
    imageAsset:    'assets/images/kasabangan.jpg',
    description:
        'A majestic multi-tiered waterfall cascading through lush tropical rainforest in '
        'Caibiran municipality. The falls feature three distinct tiers with natural pools at '
        'each level — ideal for swimming, nature photography, and trekking adventures. The '
        '30-minute forest trek to the falls is itself a rewarding nature experience.',
    categoryColor:   Color(0xFF6366F1),
    lat:             11.5900,
    lng:             124.5000,
    entranceFee:     50,
    cottageFee:      null,
    envFee:          20,
    bestSeason:      'Year-round',
    difficulty:      'Moderate',
    difficultyColor: Color(0xFFF59E0B),
    travelTime:      '1.5 hrs from Naval',
    estimatedFare:   350,
    signal:          'None',
    thingsToDo: [
      'Swimming in natural pools',
      'Multi-tier waterfall exploration',
      'Trek through tropical forest',
      'Wildlife & nature photography',
      'Cliff jumping (guided only)',
      'Picnic by the falls',
    ],
    whatToBring: [
      'Trekking shoes with grip',
      'Change of clothes & towel',
      'Waterproof bag for phone',
      'Water & energy snacks',
      'Insect repellent',
      'Basic first aid kit',
    ],
    safetyReminders: [
      'Always trek with a local guide — required',
      'No cliff jumping without lifeguard supervision',
      'Slippery rocks near falls — proceed carefully',
      'Avoid during heavy rain — flash flood risk',
      'Register at the barangay hall before entering',
    ],
    galleryAssets: [
      'assets/images/kasabangan.jpg',
      'assets/images/sambawan.jpg',
      'assets/images/maripipi.jpg',
      'assets/images/agta.JPG',
    ],
    packages: [
      TourPackage(
        name:       'Falls Adventure',
        price:      450,
        duration:   '4–6 hours',
        inclusions: ['Local guide', 'Entrance fee', 'Environmental fee'],
        isPopular:  true,
      ),
      TourPackage(
        name:       'Biliran Falls Combo',
        price:      950,
        duration:   'Full day',
        inclusions: ['3 waterfalls tour', 'Guide', 'Lunch', 'Transport'],
      ),
    ],
    recommendedRoutes: [
      RecommendedRoute(
        label:         'Best Route',
        badge:         '⭐ Recommended',
        badgeColor:    Color(0xFF1E3A8A),
        totalFare:     350,
        totalDuration: '1.5 hrs',
        isHighlighted: true,
        steps: [
          RouteStep(from: 'Naval Terminal', to: 'Caibiran Town', mode: 'Van / Bus', fare: 120, duration: '1 hr', icon: Icons.directions_bus_rounded),
          RouteStep(from: 'Caibiran Town', to: 'Kasabangan Falls', mode: 'Habal-habal', fare: 80, duration: '30 min', icon: Icons.motorcycle_rounded),
        ],
      ),
    ],
  ),

  // ── Maripipi Island ──────────────────────────────────────────────────────────
  // Coordinates: Estimated — pending field survey
  DestinationItem(
    id:            'maripipi',
    title:         'Maripipi Island',
    location:      'Maripipi, Biliran Province',
    municipality:  'Maripipi',
    province:      'Biliran Province',
    category:      'Island',
    rating:        4.7,
    imageAsset:    'assets/images/maripipi.jpg',
    description:
        'A remote volcanic island municipality with vibrant marine life, pristine coral reefs, '
        'and off-the-beaten-path charm. Maripipi serves as the gateway to Sambawan Island, but '
        'also offers its own unique attractions including white sand coves, volcanic landscape '
        'views, and authentic local fishing community experiences.',
    categoryColor:   Color(0xFF14B8A6),
    lat:             11.8083,
    lng:             124.3069,
    entranceFee:     50,
    cottageFee:      200,
    envFee:          20,
    bestSeason:      'March – July',
    difficulty:      'Moderate',
    difficultyColor: Color(0xFFF59E0B),
    travelTime:      '2.5 hrs from Naval',
    estimatedFare:   650,
    signal:          'Weak',
    thingsToDo: [
      'Snorkeling & diving at coral reefs',
      'Volcanic landscape photography',
      'Fresh seafood with local fishers',
      'Island nature walk',
      'Sambawan Island day trip from here',
      'Fishing with community guides',
    ],
    whatToBring: [
      'Reef-safe sunscreen',
      'Cash only (limited stores)',
      'Dry bag for essentials',
      'Light jacket for evening',
      'Snorkeling gear (limited rental)',
      'Extra food supplies for overnight',
    ],
    safetyReminders: [
      'Check ferry schedule in advance — irregular service',
      'Inform Maripipi LGU of your travel dates',
      'Wear life vest during all sea crossings',
      'Carry sufficient cash — no ATM on island',
    ],
    galleryAssets: [
      'assets/images/maripipi.jpg',
      'assets/images/sambawan.jpg',
      'assets/images/higatangan.jpg',
      'assets/images/dalutan.jpg',
    ],
    packages: [
      TourPackage(
        name:       'Maripipi Day Trip',
        price:      900,
        duration:   'Full day',
        inclusions: ['Ferry passage', 'Island guide', 'Island tour'],
        isPopular:  true,
      ),
      TourPackage(
        name:       'Sambawan + Maripipi',
        price:      1400,
        duration:   'Full day (2 islands)',
        inclusions: ['Boat', 'Both entrance fees', 'Guide', 'Lunch'],
      ),
    ],
    recommendedRoutes: [
      RecommendedRoute(
        label:         'Best Route',
        badge:         '⭐ Recommended',
        badgeColor:    Color(0xFF1E3A8A),
        totalFare:     650,
        totalDuration: '2.5 hrs',
        isHighlighted: true,
        steps: [
          RouteStep(from: 'Naval Port', to: 'Kawayan', mode: 'Multicab', fare: 55, duration: '45 min', icon: Icons.airport_shuttle_rounded),
          RouteStep(from: 'Kawayan Port', to: 'Maripipi Island', mode: 'Ferry / Boat', fare: 480, duration: '1.5 hrs', icon: Icons.sailing_rounded, isSeaRoute: true),
        ],
      ),
    ],
  ),

  // ── Dalutan Island ───────────────────────────────────────────────────────────
  // Coordinates: Estimated — pending field survey
  DestinationItem(
    id:            'dalutan',
    title:         'Dalutan Island',
    location:      'Almeria, Biliran Province',
    municipality:  'Almeria',
    province:      'Biliran Province',
    category:      'Beach',
    rating:        4.5,
    imageAsset:    'assets/images/dalutan.jpg',
    description:
        'A small nature reserve island off the coast of Almeria with pristine mangrove '
        'ecosystems, white sandy shores, and rich coastal biodiversity. Designated as a '
        'protected marine area, Dalutan is perfect for eco-tourism, bird watching, kayaking '
        'through mangroves, and peaceful beach escapes.',
    categoryColor:   Color(0xFF3B82F6),
    lat:             11.7778,
    lng:             124.4333,
    entranceFee:     40,
    cottageFee:      150,
    envFee:          20,
    bestSeason:      'November – April',
    difficulty:      'Easy',
    difficultyColor: Color(0xFF10B981),
    travelTime:      '1 hr from Naval',
    estimatedFare:   300,
    signal:          'Weak',
    thingsToDo: [
      'Mangrove kayaking tour',
      'Bird watching & wildlife photography',
      'Beach relaxation & swimming',
      'Eco-tour with local guide',
      'Sunset watching from shore',
    ],
    whatToBring: [
      'Binoculars for bird watching',
      'Camera with wildlife lens',
      'Reef-safe sunscreen',
      'Insect repellent',
      'Packed snacks & drinking water',
      'Cash only',
    ],
    safetyReminders: [
      'Do not disturb wildlife or mangrove roots',
      'Stay on designated eco-trail paths only',
      'Observe protected area rules — no littering',
      'Wear life vest during boat crossing',
    ],
    galleryAssets: [
      'assets/images/dalutan.jpg',
      'assets/images/agta.JPG',
      'assets/images/sambawan.jpg',
      'assets/images/higatangan.jpg',
    ],
    packages: [
      TourPackage(
        name:       'Dalutan Eco Tour',
        price:      450,
        duration:   '5–7 hours',
        inclusions: ['Boat transfer', 'Mangrove kayak', 'Guide', 'Env. fee'],
        isPopular:  true,
      ),
    ],
    recommendedRoutes: [
      RecommendedRoute(
        label:         'Best Route',
        badge:         '⭐ Recommended',
        badgeColor:    Color(0xFF1E3A8A),
        totalFare:     300,
        totalDuration: '1 hr',
        isHighlighted: true,
        steps: [
          RouteStep(from: 'Naval Port', to: 'Almeria Port', mode: 'Multicab', fare: 80, duration: '30 min', icon: Icons.airport_shuttle_rounded),
          RouteStep(from: 'Almeria Port', to: 'Dalutan Island', mode: 'Bangka Boat', fare: 200, duration: '25 min', icon: Icons.sailing_rounded, isSeaRoute: true),
        ],
      ),
    ],
  ),

  // ── Higatangan Island ────────────────────────────────────────────────────────
  // Coordinates: Estimated — pending field survey
  DestinationItem(
    id:            'higatangan',
    title:         'Higatangan Island',
    location:      'Naval, Biliran Province',
    municipality:  'Naval',
    province:      'Biliran Province',
    category:      'Island',
    rating:        4.8,
    imageAsset:    'assets/images/higatangan.jpg',
    description:
        'Often called the "Little Boracay of Biliran," Higatangan Island features a dramatic '
        'powder-white sandbar that stretches into the sea at low tide. Pristine turquoise '
        'lagoons, unspoiled natural beauty, and a peaceful atmosphere make it one of Biliran\'s '
        'most beloved island getaways. Accessible via public ferry from Naval Port.',
    categoryColor:   Color(0xFF14B8A6),
    lat:             11.5478,
    lng:             124.3194,
    entranceFee:     60,
    cottageFee:      250,
    envFee:          20,
    bestSeason:      'March – May',
    difficulty:      'Easy',
    difficultyColor: Color(0xFF10B981),
    travelTime:      '1.5 hrs from Naval',
    estimatedFare:   420,
    signal:          'Weak',
    thingsToDo: [
      'Sandbar wading & swimming',
      'Snorkeling at the reef',
      'Sandbar photography at low tide',
      'Island camping (overnight)',
      'Sunset watching from the sandbar tip',
      'Stargazing at night',
    ],
    whatToBring: [
      'Sunscreen & sun hat',
      'Swimwear & dry clothes',
      'Cash only (no stores on island)',
      'Tent for overnight stays',
      'Drinking water (limited supply)',
      'Portable power bank & torch',
    ],
    safetyReminders: [
      'Sandbar submerges at high tide — plan timing accordingly',
      'Ferry runs on fixed schedule — confirm at Naval Port',
      'No electricity on island — bring torch for overnight',
      'Register at barangay tourism office upon arrival',
    ],
    galleryAssets: [
      'assets/images/higatangan.jpg',
      'assets/images/sambawan.jpg',
      'assets/images/dalutan.jpg',
      'assets/images/agta.JPG',
    ],
    packages: [
      TourPackage(
        name:       'Higatangan Day Trip',
        price:      550,
        duration:   '8 hours',
        inclusions: ['Ferry ticket', 'Cottage rental', 'Guide fee'],
        isPopular:  true,
      ),
      TourPackage(
        name:       'Overnight Sandbar Camp',
        price:      1100,
        duration:   '2 days / 1 night',
        inclusions: ['Ferry (2-way)', 'Tent', 'Meals (2x)', 'Guide'],
      ),
    ],
    recommendedRoutes: [
      RecommendedRoute(
        label:         'Best Route',
        badge:         '⭐ Recommended',
        badgeColor:    Color(0xFF1E3A8A),
        totalFare:     420,
        totalDuration: '1.5 hrs',
        isHighlighted: true,
        steps: [
          RouteStep(from: 'Naval Port', to: 'Higatangan Island', mode: 'Public Ferry', fare: 150, duration: '1.5 hrs', icon: Icons.directions_boat_rounded, isSeaRoute: true),
        ],
      ),
      RecommendedRoute(
        label:         'Express Route',
        badge:         '⚡ Fastest',
        badgeColor:    Color(0xFFF59E0B),
        totalFare:     1000,
        totalDuration: '45 min',
        steps: [
          RouteStep(from: 'Naval Port', to: 'Higatangan Island', mode: 'Charter Boat', fare: 1000, duration: '45 min', icon: Icons.sailing_rounded, isSeaRoute: true),
        ],
      ),
    ],
  ),
];
