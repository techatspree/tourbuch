import 'package:collection/collection.dart';

import '../dao/person_dao.dart';
import '../models/person.dart';
import '../models/product_order.dart';
import 'product_order_repository.dart';

class PersonRepository {
  final _personDao = PersonDao();
  final _productOrderRepository = ProductOrderRepository();

  Future<int> createPerson(Person person) => _personDao.createPerson(person);

  Future<int> updatePerson(Person person) => _personDao.updatePerson(person);

  Future<Person?> getPersonById(int id) => _personDao.getPersonById(id);

  Future<List<Person>> getAllPersons() => _personDao.getAllPersons();

  Future<Person> mergePersons(Person person, Person personToMerge) async {
    await _personDao.updatePerson(person);

    final orders =
        await _productOrderRepository.getProductOrdersByPersonId(person.id);
    final ordersToMerge = await _productOrderRepository
        .getProductOrdersByPersonId(personToMerge.id);

    for (final orderToMerge in ordersToMerge) {
      final orderToUpdate = orders.firstWhereOrNull(
          (order) => order.productTypeId == orderToMerge.productTypeId);

      if (orderToUpdate != null) {
        await _mergeOrders(orderToUpdate, orderToMerge);
      } else {
        await _productOrderRepository
            .updateProductOrder(orderToMerge.copyWith(personId: person.id));
      }
    }

    await _personDao.delete(personToMerge.id);

    return person;
  }

  /// logic to merge by status:
  /// when notOrdered & notOrdered => notOrdered
  /// when notOrdered & ordered => ordered
  /// when notOrdered & received => received
  /// when ordered & ordered => min(lastIssueDate)
  /// when ordered & received => max(o1.lastIssueDate, o2.lastReceivedDate)
  /// when received & ordered => max(o1.lastReceivedDate, o2.lastIssueDate)
  /// when received & received => max(lastReceivedDate)
  Future<void> _mergeOrders(
      ProductOrder orderToUpdate, ProductOrder orderToMerge) async {
    // @formatter:off
    final dominantOrder = switch ((orderToUpdate, orderToMerge)) {
      (final a, final b) when isNotOrdered(a) && isNotOrdered(b)  => a,
      (final a, final b) when isNotOrdered(a) && isOrdered(b)     => b,
      (final a, final b) when isNotOrdered(a) && isReceived(b)    => b,

      (final a, final b) when isOrdered(a)    && isNotOrdered(b)  => a,
      (final a, final b) when isReceived(a)   && isNotOrdered(b)  => a,

      (final a, final b) when isOrdered(a)    && isOrdered(b)     => minBy(a, b)((x) => x.lastIssueDate, (y) => y.lastIssueDate),
      (final a, final b) when isOrdered(a)    && isReceived(b)    => maxBy(a, b)((x) => x.lastIssueDate, (y) => y.lastReceivedDate),
      (final a, final b) when isReceived(a)   && isOrdered(b)     => maxBy(a, b)((x) => x.lastReceivedDate, (y) => y.lastIssueDate),
      (final a, final b) when isReceived(a)   && isReceived(b)    => maxBy(a, b)((x) => x.lastReceivedDate, (y) => y.lastReceivedDate),

      (final _, final _) => throw UnimplementedError('case not implemented'),
    };
    // @formatter:on

    await _productOrderRepository.updateProductOrder(orderToUpdate.copyWith(
      lastIssueDate: dominantOrder.lastIssueDate,
      lastReceivedDate: dominantOrder.lastReceivedDate,
    ));
    await _productOrderRepository.delete(orderToMerge);
  }
}

// max order by accessors (nullable values are disadvantaged)
ProductOrder Function(DateTime? Function(ProductOrder p1) aDateFn,
    DateTime? Function(ProductOrder p1) bDateFn) minBy(
        ProductOrder a, ProductOrder b) =>
    (DateTime? Function(ProductOrder) aDateFn,
        DateTime? Function(ProductOrder) bDateFn) {
      final aDate = aDateFn(a);
      final bDate = bDateFn(b);
      if (aDate == null && bDate == null) {
        return a;
      } else if (aDate == null) {
        return b;
      } else if (bDate == null) {
        return a;
      }

      return aDate.isBefore(bDate) ? a : b;
    };

// min order by accessors (nullable values are disadvantaged)
ProductOrder Function(DateTime? Function(ProductOrder p1) aDateFn,
    DateTime? Function(ProductOrder p1) bDateFn) maxBy(
        ProductOrder a, ProductOrder b) =>
    (DateTime? Function(ProductOrder) aDateFn,
        DateTime? Function(ProductOrder) bDateFn) {
      final aDate = aDateFn(a);
      final bDate = bDateFn(b);
      if (aDate == null && bDate == null) {
        return a;
      } else if (aDate == null) {
        return b;
      } else if (bDate == null) {
        return a;
      }

      return aDate.isAfter(bDate) ? a : b;
    };
