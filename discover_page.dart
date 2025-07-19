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
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      List<Article> allArticles = [];
      
      // Use a simpler approach with a news API service
      // Since direct RSS parsing might have CORS issues, we'll use a news aggregator API
      final response = await http.get(
        Uri.parse('https://newsapi.org/v2/top-headlines?country=in&pageSize=20&apiKey=demo'), // You'll need to get a free API key
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

      // Add some international news
      final intlResponse = await http.get(
        Uri.parse('https://newsapi.org/v2/top-headlines?country=us&pageSize=15&apiKey=demo'),
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

      // If NewsAPI doesn't work (demo key limitations), add some sample articles
      if (allArticles.isEmpty) {
        allArticles = _getSampleArticles();
      }

      setState(() {
        _articles = allArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load news. Using sample data.';
        _articles = _getSampleArticles();
        _isLoading = false;
      });
    }
  }

  List<Article> _getSampleArticles() {
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
      backgroundColor: const Color(0xFFF7F7F7),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFFF7F7F7),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Discover',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 24,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
              automaticallyImplyLeading: false,
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.black87,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'All News'),
                    Tab(text: 'India'),
                    Tab(text: 'World'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _fetchNews,
          color: Colors.black87,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black87,
                  ),
                )
              : _error.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _error,
                            style: TextStyle(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchNews,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildArticlesList(_articles),
                        _buildArticlesList(_articles.where((a) => a.category == 'Indian').toList()),
                        _buildArticlesList(_articles.where((a) => a.category == 'International').toList()),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildArticlesList(List<Article> articles) {
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No articles available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull to refresh',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) => ArticleCard(article: articles[index]),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF7F7F7),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchUrl(article.url),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (article.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey.shade400,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade400,
                        size: 48,
                      ),
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source and time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            article.source,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeago.format(article.publishedAt),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: article.category == 'Indian' 
                                ? Colors.orange.shade100 
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.category,
                            style: TextStyle(
                              color: article.category == 'Indian' 
                                  ? Colors.orange.shade700 
                                  : Colors.blue.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Read more button
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _launchUrl(article.url),
                          icon: const Icon(Icons.arrow_outward, size: 16),
                          label: const Text('Read more'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            // TODO: Add bookmark functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bookmark functionality coming soon!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.bookmark_border,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
}

class RSSSource {
  final String name;
  final String url;
  final String category;

  RSSSource(this.name, this.url, this.category);
}