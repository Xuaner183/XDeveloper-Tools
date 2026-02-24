import { Home } from './Home';
@Entry
@ComponentV2
struct Index {
  build() {
    Column(){
      Home();
    }
  }
}