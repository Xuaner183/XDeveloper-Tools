import { SearchComponent, SearchController } from 'search';
import { ExamDetail, getQuestionType } from 'exam';
import { HdsNavDestination } from '@kit.UIDesignKit';

@ComponentV2
export struct SearchItem {
  private mainNavPathStack: NavPathStack = new NavPathStack();


  build() {
    HdsNavDestination() {
      Column() {

      }
    }
    .onReady((ctx) => {
      this.mainNavPathStack = ctx.pathStack;
    })
  }
}