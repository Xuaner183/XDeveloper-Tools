export class TextOverlayStyle implements AttributeModifier<TextAttribute> {
  applyNormalAttribute(i: TextAttribute): void {
    i.fontColor(Color.White);
    i.textShadow({
      radius: 8,
    });
    i.fontWeight(FontWeight.Bold)
    i.lineBreakStrategy(LineBreakStrategy.BALANCED)
    i.minFontSize(4)
    i.maxFontSize(18)
    i.heightAdaptivePolicy(TextHeightAdaptivePolicy.LAYOUT_CONSTRAINT_FIRST)
    i.textOverflow({ overflow: TextOverflow.Ellipsis })
    i.wordBreak(WordBreak.NORMAL)
    i.textAlign(TextAlign.Center)
  }
}
