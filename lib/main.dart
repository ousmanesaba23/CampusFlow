import 'package:flutter/material.dart';

void main() => runApp(const CampusFlowApp());

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF426BCE);
    return MaterialApp(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, surface: const Color(0xFFF8F9FC)),
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE7EAF1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: seed, width: 1.5)),
        ),
      ),
      home: const CampusHome(),
    );
  }
}

class Exchange {
  Exchange({required this.title, required this.category, required this.description, required this.owner, required this.icon, this.done = false});
  final String title;
  final String category;
  final String description;
  final String owner;
  final IconData icon;
  bool done;
}

class CampusHome extends StatefulWidget {
  const CampusHome({super.key});
  @override
  State<CampusHome> createState() => _CampusHomeState();
}

class _CampusHomeState extends State<CampusHome> {
  final exchanges = <Exchange>[
    Exchange(title: 'Cours de Python', category: 'Informatique', description: 'Je propose une séance de révision sur les bases de Python : variables, boucles et fonctions. Niveau débutant bienvenu !', owner: 'Aïcha K.', icon: Icons.code_rounded),
    Exchange(title: 'Conversation en anglais', category: 'Langues', description: 'Échangeons autour d’un café pour pratiquer l’anglais à l’oral. Je peux aider en français en retour.', owner: 'Moussa T.', icon: Icons.translate_rounded),
    Exchange(title: 'Aide en mathématiques', category: 'Sciences', description: 'Révisions d’algèbre et de statistiques avant les examens. On peut travailler à la bibliothèque.', owner: 'Fatou D.', icon: Icons.functions_rounded),
    Exchange(title: 'Initiation au design', category: 'Créativité', description: 'Découverte des principes de composition et de couleur. Apportez vos idées de projet !', owner: 'Issa B.', icon: Icons.palette_outlined),
  ];
  int selected = 0;
  int tab = 0;
  String query = '';

  List<int> get visibleIndexes => List.generate(exchanges.length, (i) => i).where((i) {
    final e = exchanges[i];
    final matchesTab = tab == 1 ? e.done : tab == 0 ? !e.done : true;
    final matchesQuery = '${e.title} ${e.category} ${e.owner}'.toLowerCase().contains(query.toLowerCase());
    return matchesTab && matchesQuery;
  }).toList();

  Future<void> addExchange() async {
    final result = await showDialog<Exchange>(context: context, builder: (_) => const ExchangeForm());
    if (result != null && mounted) setState(() { exchanges.insert(0, result); selected = 0; tab = 0; });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final tablet = constraints.maxWidth >= 840;
      final indexes = visibleIndexes;
      if (indexes.isNotEmpty && !indexes.contains(selected)) selected = indexes.first;
      return Scaffold(
        appBar: AppBar(
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20)),
            const SizedBox(width: 10), const Text('CampusFlow', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ]),
          actions: [Padding(padding: const EdgeInsets.only(right: 18), child: CircleAvatar(radius: 18, backgroundColor: const Color(0xFFE7ECFA), child: Text('OS', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))))],
        ),
        body: SafeArea(child: tablet
          ? Padding(padding: const EdgeInsets.fromLTRB(28, 14, 28, 18), child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(width: 360, child: _listPanel(indexes, tablet: true)),
              const SizedBox(width: 22),
              Expanded(child: _detailPanel(indexes.isEmpty ? null : exchanges[selected])),
            ]))
          : _listPanel(indexes, tablet: false)),
        floatingActionButton: FloatingActionButton.extended(onPressed: addExchange, icon: const Icon(Icons.add), label: const Text('Proposer un échange')),
        bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (value) => setState(() => tab = value), destinations: const [
          NavigationDestination(icon: Icon(Icons.swap_horiz_rounded), label: 'Échanges'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline_rounded), label: 'Terminés'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
        ]),
      );
    });
  }

  Widget _listPanel(List<int> indexes, {required bool tablet}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: EdgeInsets.fromLTRB(tablet ? 4 : 22, 12, tablet ? 4 : 22, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('LE CAMPUS, ENSEMBLE', style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
      const SizedBox(height: 6), const Text('Échanges', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, letterSpacing: -1)),
      const SizedBox(height: 5), Text('Apprenez et partagez avec votre communauté.', style: TextStyle(color: Colors.blueGrey.shade600)),
      const SizedBox(height: 17), TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(hintText: 'Rechercher un échange', prefixIcon: Icon(Icons.search_rounded))),
    ])),
    Expanded(child: indexes.isEmpty ? const Center(child: Text('Aucun échange pour le moment.')) : ListView.builder(padding: EdgeInsets.fromLTRB(tablet ? 4 : 18, 0, tablet ? 4 : 18, 90), itemCount: indexes.length, itemBuilder: (_, i) {
      final index = indexes[i]; final e = exchanges[index]; final active = selected == index;
      return Card(color: active && tablet ? const Color(0xFFEDF1FC) : Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: active && tablet ? Theme.of(context).colorScheme.primary.withValues(alpha: .35) : const Color(0xFFE9ECF2))), child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        leading: CircleAvatar(backgroundColor: const Color(0xFFEFF2FA), child: Icon(e.icon, color: Theme.of(context).colorScheme.primary, size: 20)),
        title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text('${e.category}  ·  ${e.owner}', maxLines: 1, overflow: TextOverflow.ellipsis)),
        trailing: e.done ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.chevron_right_rounded),
        onTap: () => setState(() => selected = index),
      ));
    })),
  ]);

  Widget _detailPanel(Exchange? exchange) {
    if (exchange == null) return const Card(child: Center(child: Text('Sélectionnez un échange pour voir les détails.')));
    return Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFE9ECF2))), child: Padding(padding: const EdgeInsets.all(32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 58, height: 58, decoration: BoxDecoration(color: const Color(0xFFEEF2FC), borderRadius: BorderRadius.circular(18)), child: Icon(exchange.icon, color: Theme.of(context).colorScheme.primary, size: 28)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(exchange.category.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, letterSpacing: 1.3, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(exchange.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.6))]))]),
      const SizedBox(height: 30), const Text('À PROPOS', style: TextStyle(fontSize: 11, letterSpacing: 1.3, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      const SizedBox(height: 10), Text(exchange.description, style: const TextStyle(height: 1.65, fontSize: 15, color: Color(0xFF4E586B))),
      const SizedBox(height: 28), const Divider(), const SizedBox(height: 17),
      Row(children: [const CircleAvatar(child: Icon(Icons.person_outline)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Proposé par', style: TextStyle(fontSize: 12, color: Colors.blueGrey)), Text(exchange.owner, style: const TextStyle(fontWeight: FontWeight.w700))])]),
      const Spacer(),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: exchange.done ? null : () async { setState(() => exchange.done = true); await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Échange terminé'), content: const Text('Cet échange a été marqué comme terminé.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Compris'))])); }, icon: Icon(exchange.done ? Icons.check_circle_outline : Icons.done_all_rounded), label: Text(exchange.done ? 'Échange terminé' : 'Marquer comme fait'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)))),
    ])));
  }
}

class ExchangeForm extends StatefulWidget {
  const ExchangeForm({super.key});
  @override
  State<ExchangeForm> createState() => _ExchangeFormState();
}

class _ExchangeFormState extends State<ExchangeForm> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final ownerController = TextEditingController();
  String category = 'Informatique';
  final categories = const ['Informatique', 'Langues', 'Sciences', 'Créativité', 'Autre'];

  @override
  void dispose() { titleController.dispose(); descriptionController.dispose(); ownerController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Proposer un échange', style: TextStyle(fontWeight: FontWeight.w800)),
    content: SizedBox(width: 440, child: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextFormField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre', hintText: 'Ex. Atelier de photographie'), validator: (v) => v == null || v.trim().length < 3 ? 'Saisissez au moins 3 caractères.' : null),
      const SizedBox(height: 13), DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Catégorie'), items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => category = v ?? category)),
      const SizedBox(height: 13), TextFormField(controller: descriptionController, minLines: 3, maxLines: 4, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true), validator: (v) => v == null || v.trim().length < 10 ? 'Décrivez votre échange en 10 caractères minimum.' : null),
      const SizedBox(height: 13), TextFormField(controller: ownerController, decoration: const InputDecoration(labelText: 'Votre nom'), validator: (v) => v == null || v.trim().isEmpty ? 'Indiquez votre nom.' : null),
    ]))),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')), FilledButton(onPressed: () { if (!formKey.currentState!.validate()) return; Navigator.pop(context, Exchange(title: titleController.text.trim(), category: category, description: descriptionController.text.trim(), owner: ownerController.text.trim(), icon: category == 'Langues' ? Icons.translate_rounded : category == 'Sciences' ? Icons.functions_rounded : category == 'Créativité' ? Icons.palette_outlined : Icons.school_rounded)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votre échange a été ajouté !'), behavior: SnackBarBehavior.floating)); }, child: const Text('Publier'))],
  );
}
