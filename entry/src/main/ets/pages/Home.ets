
@ComponentV2
export struct Home {
  private mainNavPathStack: NavPathStack = new NavPathStack();


  build() {
    Navigation(this.mainNavPathStack){
      Column() {
        Button('Color', { type: ButtonType.Normal })
          .onClick(() => {
            this.mainNavPathStack.pushPath({
              name: 'Colors'
            })
          })
      }
      .width('100%')
      .height('100%')
    }
    .title('主页')
  }
}