import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 247, 13, 13)),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();  // pick-up random word pair
  var history = <WordPair>[];
  GlobalKey? historyListenerKey;
  void getNext(){ //added getNext method
    history.insert(0, current);
    var animatedList = historyListenerKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current=WordPair.random();
    notifyListeners();
  }
  var favorites = <WordPair>[]; // here [] is list(empty list)
  void toggleFavorite([WordPair? pair]){
    pair=pair ?? current;
    if(favorites.contains(pair)){
      favorites.remove(pair);
    }else{
      favorites.add(pair);
    }
    // notifyListeners();
  }
  void removeFavorite(WordPair pair){
  favorites.remove(pair);
  notifyListeners();
}
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex=0;  // for navigation rail items(home and like)
  @override
  Widget build(BuildContext context) {
    var colorScheme=Theme.of(context).colorScheme;

    Widget page;
    switch(selectedIndex){
      case 0:
      page=const GeneratorPage();
      break;
      case 1:
      page=const FavoritesPage();
      break;
    default:
    throw UnimplementedError('no weidget for $selectedIndex');
    } 
    int millisec=0;
    var mainArea=ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: millisec),
        child: page,
        ),
    );

     return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}
class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          const SizedBox(height: 10),
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}


// FavoritesPage class starts
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        Expanded(
          // Make better use of wide windows with a grid.
          child: GridView(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                  title: Text(
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
// FavoritesPage class ends



// Bigcard class starts. add a new card as Bigcard

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme =Theme.of(context);
    var style=theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return  Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
      
        child: MergeSemantics(
          child: Wrap(
            children: [
          Text(
            pair.first,
            style: style.copyWith(fontWeight: FontWeight.w200),
          ),
          Text(pair.second,
          style: style.copyWith(fontWeight: FontWeight.bold),)
        ],),
        ),
        ),
      ),
    );
  }
} // end of Bigcard class
class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}):super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key =GlobalKey();
  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent,Colors.black],
  stops: [0.0,0.5],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  );
  @override
  Widget build(BuildContext context) {
    final appState=context.watch<MyAppState>();
    appState.historyListenerKey=_key;

    return ShaderMask(shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
    blendMode: BlendMode.dstIn,
    child: AnimatedList(key: _key,
    reverse: true,
    padding: const EdgeInsets.only(top: 100),
    initialItemCount: appState.history.length,

    itemBuilder: (context, index, animation){
      final pair =appState.history[index];
      return SizeTransition(sizeFactor: animation,
      child: Center(child: TextButton.icon(onPressed: (){
        appState.toggleFavorite(pair);
      },
      icon: appState.favorites.contains(pair)? const Icon(Icons.favorite,size: 12,)
      :const SizedBox(),
      label: Text(pair.asLowerCase,
      semanticsLabel: pair.asPascalCase,
      ),
      ),
      ),
      );
    },
    ),
    );
  }
}