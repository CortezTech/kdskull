class KitchenStatus {
  const KitchenStatus._();

  static const String todo = 'todo';
  static const String inProgress = 'in_progress';
  static const String ready = 'ready';
}

class KitchenBoardColumn {
  const KitchenBoardColumn({required this.status, required this.title});

  final String status;
  final String title;
}

const List<KitchenBoardColumn> kitchenBoardColumns = <KitchenBoardColumn>[
  KitchenBoardColumn(status: KitchenStatus.todo, title: 'Pendiente'),
  KitchenBoardColumn(status: KitchenStatus.inProgress, title: 'En marcha'),
  KitchenBoardColumn(status: KitchenStatus.ready, title: 'Listo'),
];

const double kitchenBoardSpacing = 12;
const double kitchenBoardMinColumnWidth = 300;
const double kitchenBoardMaxWidth = 1900;
