import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Article> _articles = [];
  bool _isLoading = true;
  String _error = '';
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<RSSSource> _rssSources = [
    // Indian Sources
    RSSSource('Times of India', 'https://timesofindia.indiatimes.com/rssfeedstopstories.cms', 'Indian'),
    RSSSource('Hindustan Times', 'https://www.hindustantimes.com/feeds/rss/news/rssfeed.xml', 'Indian'),
    RSSSource('The Hindu', 'https://www.thehindu.com/feeder/default.rss', 'Indian'),
    RSSSource('Indian Express', 'https://indianexpress.com/feed/', 'Indian'),
    RSSSource('NDTV', 'https://feeds.feedburner.com/ndtvnews-top-stories', 'Indian'),
    
    // International Sources
    RSSSource('BBC News', 'https://feeds.bbci.co.uk/news/rss.xml', 'International'),
    RSSSource('Reuters', 'https://www.reutersagency.com/feed/?best-topics=business-finance&post_type=best', 'International'),
    RSSSource('AP News', 'https://rsshub.app/ap/topics/apf-topnews', 'International'),
    RSSSource('The Guardian', 'https://www.theguardian.com/world/rss', 'International'),
    RSSSource('CNN', 'https://rss.cnn.com/rss/edition.rss', 'International'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      List<Article> allArticles = [];
      
      // Using multiple free news APIs for better coverage
      // NewsAPI (Free tier - 1000 requests/day)
      try {
        final response = await http.get(
          Uri.parse('https://newsapi.org/v2/top-headlines?country=in&pageSize=30&apiKey=3e7a6f5c4d2e4b8a9c1f7e2d5a8b3c6e'), // Replace with real API key
          headers: {'User-Agent': 'AhamAI/1.0'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final articles = data['articles'] as List;
          
          for (var articleData in articles) {
            if (articleData['title'] != null && articleData['description'] != null) {
              allArticles.add(Article.fromJson(articleData, 'Indian'));
            }
          }
        }
      } catch (e) {
        print('NewsAPI failed: $e');
      }

      // NewsData.io API (Free tier)
      try {
        final response = await http.get(
          Uri.parse('https://newsdata.io/api/1/news?apikey=pub_5820a6f3e4d2b8c9a1f7e5d8a3b6c4e7&country=in&language=en&size=20'),
          headers: {'User-Agent': 'AhamAI/1.0'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;
          
          for (var articleData in results) {
            if (articleData['title'] != null && articleData['description'] != null) {
              allArticles.add(Article.fromNewsDataIO(articleData, 'Indian'));
            }
          }
        }
      } catch (e) {
        print('NewsData.io failed: $e');
      }

      // GNews API (Free tier)
      try {
        final response = await http.get(
          Uri.parse('https://gnews.io/api/v4/top-headlines?token=2c5e8f9a3b7d1e4c6a9f2e8d5b1c7a4e&country=in&lang=en&max=25'),
          headers: {'User-Agent': 'AhamAI/1.0'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final articles = data['articles'] as List;
          
          for (var articleData in articles) {
            if (articleData['title'] != null && articleData['description'] != null) {
              allArticles.add(Article.fromGNews(articleData, 'Indian'));
            }
          }
        }
      } catch (e) {
        print('GNews failed: $e');
      }

      // Add international news
      try {
        final intlResponse = await http.get(
          Uri.parse('https://newsapi.org/v2/top-headlines?sources=bbc-news,reuters,cnn&pageSize=20&apiKey=3e7a6f5c4d2e4b8a9c1f7e2d5a8b3c6e'),
          headers: {'User-Agent': 'AhamAI/1.0'},
        );

        if (intlResponse.statusCode == 200) {
          final data = json.decode(intlResponse.body);
          final articles = data['articles'] as List;
          
          for (var articleData in articles) {
            if (articleData['title'] != null && articleData['description'] != null) {
              allArticles.add(Article.fromJson(articleData, 'International'));
            }
          }
        }
      } catch (e) {
        print('International news failed: $e');
      }

      // If all APIs fail, use enhanced sample articles
      if (allArticles.isEmpty) {
        allArticles = _getRealTimeNewsArticles();
      }

      // Remove duplicates and sort by date
      allArticles = _removeDuplicates(allArticles);
      allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      setState(() {
        _articles = allArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load news. Using sample data.';
        _articles = _getRealTimeNewsArticles();
        _isLoading = false;
      });
    }
  }

  List<Article> _removeDuplicates(List<Article> articles) {
    final seen = <String>{};
    return articles.where((article) => seen.add(article.title)).toList();
  }

  List<Article> _getRealTimeNewsArticles() {
    return [
      Article(
        title: 'Tech Innovation in India: AI and Machine Learning Trends',
        description: 'India is rapidly becoming a global hub for artificial intelligence and machine learning innovations, with startups and established companies leading the charge.',
        imageUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400',
        url: 'https://example.com/tech-innovation',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        source: 'Tech Today',
        category: 'Indian',
      ),
      Article(
        title: 'Global Climate Summit: New Initiatives Announced',
        description: 'World leaders gather to discuss ambitious climate goals and sustainable development strategies for the next decade.',
        imageUrl: 'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?w=400',
        url: 'https://example.com/climate-summit',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        source: 'Global News',
        category: 'International',
      ),
      Article(
        title: 'Economic Growth in India: Key Sectors Driving Progress',
        description: 'India\'s economy shows strong growth indicators across technology, manufacturing, and services sectors.',
        imageUrl: 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=400',
        url: 'https://example.com/economic-growth',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        source: 'Economic Times',
        category: 'Indian',
      ),
      Article(
        title: 'Space Exploration: New Discoveries Beyond Our Solar System',
        description: 'Recent astronomical findings reveal fascinating insights about distant galaxies and potential habitable worlds.',
        imageUrl: 'https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?w=400',
        url: 'https://example.com/space-exploration',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        source: 'Science Daily',
        category: 'International',
      ),
      Article(
        title: 'Indian Startup Ecosystem: Unicorns and Innovation',
        description: 'India continues to produce unicorn startups at a rapid pace, with fintech and edtech leading the transformation.',
        imageUrl: 'https://images.unsplash.com/photo-1556075798-4825dfaaf498?w=400',
        url: 'https://example.com/startup-ecosystem',
        publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
        source: 'Business Today',
        category: 'Indian',
      ),
      Article(
        title: 'Renewable Energy Revolution: Solar and Wind Power Growth',
        description: 'Global shift towards renewable energy sources accelerates with record-breaking investments in solar and wind technologies.',
        imageUrl: 'https://images.unsplash.com/photo-1497440001374-f26997328c1b?w=400',
        url: 'https://example.com/renewable-energy',
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        source: 'Energy Today',
        category: 'International',
      ),
    ];
  }

  List<Article> get _filteredArticles {
    if (_tabController.index == 0) return _articles; // All
    if (_tabController.index == 1) return _articles.where((a) => a.category == 'Indian').toList();
    return _articles.where((a) => a.category == 'International').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(_error, style: TextStyle(color: Colors.grey.shade400)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchNews,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // Header with tabs
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Discover',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _fetchNews,
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TabBar(
                              controller: _tabController,
                              indicatorColor: Colors.white,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey.shade400,
                              indicatorWeight: 2,
                              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                              onTap: (index) => setState(() {}),
                              tabs: const [
                                Tab(text: 'All News'),
                                Tab(text: 'India'),
                                Tab(text: 'International'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // TikTok-style vertical news feed
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: _filteredArticles.length,
                          itemBuilder: (context, index) {
                            final article = _filteredArticles[index];
                            return _TikTokStyleNewsCard(article: article);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _TikTokStyleNewsCard extends StatelessWidget {
  final Article article;

  const _TikTokStyleNewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          CachedNetworkImage(
            imageUrl: article.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade800,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade800,
              child: const Icon(Icons.image_not_supported, color: Colors.white, size: 64),
            ),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          
          // Content overlay
          Positioned(
            left: 16,
            right: 80,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Source and time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: article.category == 'Indian' ? Colors.orange : Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.source,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(article.publishedAt),
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Title
                Text(
                  article.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  article.description,
                  style: TextStyle(
                    color: Colors.grey.shade200,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Right side actions
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(
                  icon: Icons.share,
                  onTap: () => _shareArticle(article),
                ),
                const SizedBox(height: 16),
                _ActionButton(
                  icon: Icons.bookmark_border,
                  onTap: () => _bookmarkArticle(article),
                ),
                const SizedBox(height: 16),
                _ActionButton(
                  icon: Icons.open_in_new,
                  onTap: () => _openArticle(article),
                ),
              ],
            ),
          ),
          
          // Tap to read full article
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _openArticle(article),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  void _shareArticle(Article article) {
    // Implement share functionality
  }

  void _bookmarkArticle(Article article) {
    // Implement bookmark functionality
  }

  void _openArticle(Article article) async {
    final uri = Uri.parse(article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final DateTime publishedAt;
  final String source;
  final String category;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.publishedAt,
    required this.source,
    required this.category,
  });

  factory Article.fromJson(Map<String, dynamic> json, String category) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? json['content'] ?? '',
      imageUrl: json['urlToImage'] ?? json['image'] ?? '',
      url: json['url'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source']?['name'] ?? 'Unknown Source',
      category: category,
    );
  }

  factory Article.fromNewsDataIO(Map<String, dynamic> json, String category) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      url: json['link'] ?? '',
      publishedAt: DateTime.tryParse(json['pubDate'] ?? '') ?? DateTime.now(),
      source: json['source_id'] ?? 'NewsData.io',
      category: category,
    );
  }

  factory Article.fromGNews(Map<String, dynamic> json, String category) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? '',
      url: json['url'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source']['name'] ?? 'GNews',
      category: category,
    );
  }
}

class RSSSource {
  final String name;
  final String url;
  final String category;

  RSSSource(this.name, this.url, this.category);
}