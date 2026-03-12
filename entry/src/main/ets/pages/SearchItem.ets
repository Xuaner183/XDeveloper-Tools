import { HdsNavDestination } from '@kit.UIDesignKit';

@Builder export function SearchItemBuilder() {
  SearchItem();
}


@ComponentV2
export struct SearchItem {
  @Provider('mainNavPathStack') private mainNavPathStack: NavPathStack = new NavPathStack();


  build() {
    HdsNavDestination() {
    }
  }
}