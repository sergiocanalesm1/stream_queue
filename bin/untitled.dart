import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'dart:math';



class QueueHelper{
  static Future<Null> isWorking;
  static Completer<Null> completer;
  static Queue<int> queue = Queue<int>();
  static final StreamController<int> _controller = BehaviorSubject<int>();

  static Stream<int> stream() => _controller.stream;

  static void fillQueue(){
    for(var i = 0; i < 10; i++){
      queue.add( i+1 );
    }
  }

  static Future<void> administrador() async {
    if ( isWorking != null ){
      print("waiting");
      await isWorking;
      return administrador();
    }
    completer = Completer<Null>();
    isWorking =  completer.future;
    await ventana();
  }

  static Stream<int> carpintero( { chance = 10 } ) async* {
    var randomGen = Random();
    while( QueueHelper.queue.isNotEmpty ){
      var random = randomGen.nextInt( 15 );
      var current = QueueHelper.queue.first;
      if ( random > chance) {
        yield throw Exception( "random de $random" );
      }
      yield await Future.delayed( Duration( seconds: 1 ), () => current );
      QueueHelper.queue.removeFirst();
    }
    completer.complete();
    isWorking = null;
  }

  static void ventana() async {
    if( QueueHelper.queue.isNotEmpty ){
        carpintero().handleError(( error ){
        print( "erroooooor capturado en stream 1, ${ error.toString() }");
        Future.delayed( Duration( seconds: 1 ), () => ventana() );
      })
      .listen(( event ){
        _controller.sink.add( event );
      }, cancelOnError: false, );

    }
  }

}

void main( List<String> arguments ) {
  QueueHelper.fillQueue();

  QueueHelper.stream()
    .where(( event ) => event % 2 == 0 )
    .map(( event ) => "es par $event" )
    .listen(( event ) {
      print( event );
      },
    );

  QueueHelper.stream()
    .where(( event ) => event % 2 != 0 )
    .map(( event ) => "es impar $event" )
    .listen( print );



  QueueHelper.administrador();
  QueueHelper.administrador();
  QueueHelper.administrador();
   //QueueHelper.administrador_carpinteria();
  //validar que no se ejecute si ya hay una en ejecucion -- encontrar forma de hacer el analogo a synchronize de java
}