import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password,
    String name,
  );
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}
