import { Home } from './Home';
export { CurrentModeData } from '../myabilitystage/MyAbilityStage'
@Entry
@ComponentV2
struct Index {
  build() {
    Column(){
      Home();
    }
  }
}