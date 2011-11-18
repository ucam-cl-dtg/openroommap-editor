package ojw28 {
    // Import the required component classes.
    import fl.controls.listClasses.CellRenderer;
    import fl.controls.listClasses.ICellRenderer;
	import flash.text.*;
	
    /**
     * This class sets the upSkin style based on the current item's rowColor value 
     * in the data provider.
     * Make sure the class is marked "public" and in the case of our custom cell renderer, 
     * extends the CellRenderer class and implements the ICellRenderer interface.
     */
    public class ComponentsListRenderer extends CellRenderer implements ICellRenderer {


		private var mHeadingFormat:TextFormat;
		private var mItemFormat:TextFormat;
		
        /**
         * Constructor.
         */
        public function ComponentsListRenderer():void {
			mHeadingFormat = new TextFormat();
			mHeadingFormat.color = 0xFFFFFF;
			mHeadingFormat.bold = true;
			
			mItemFormat = new TextFormat();
			mItemFormat.color = 0x000000;
			mItemFormat.bold = false;
			
            super();
        }

        /**
         * This method returns the style definition object from the CellRenderer class.
         */
        public static function getStyleDefinition():Object {
            return CellRenderer.getStyleDefinition();
        }

        /** 
         * This method overrides the inherited drawBackground() method and sets the renderer's
         * upSkin style based on the row's rowColor value in the data provider. For example, 
         * if the item's rowColor value is "green," the upSkin style is set to the 
         * CellRenderer_upSkinGreen linkage in the library. If the rowColor value is "red," the
         * upSkin style is set to the CellRenderer_upSkinRed linkage in the library.
         */
        override protected function drawBackground():void {
			if(data.category != null) {
            	setStyle("downSkin", CellRenderer_headingSkin);
            	setStyle("upSkin", CellRenderer_headingSkin);
             	setStyle("overSkin", CellRenderer_headingSkin);
             	setStyle("disabledSkin", CellRenderer_headingSkin);
             	setStyle("selectedDownSkin", CellRenderer_headingSkin);
             	setStyle("selectedOverSkin", CellRenderer_headingSkin);
             	setStyle("selectedUpSkin", CellRenderer_headingSkin);
           		setStyle("textFormat", mHeadingFormat);
			}
			else
			{
				clearStyle("downSkin");
				clearStyle("upSkin");
				clearStyle("overSkin");
				clearStyle("disabledSkin");
				clearStyle("selectedDownSkin");
				clearStyle("selectedOverSkin");
				clearStyle("selectedUpSkin");
           		setStyle("textFormat", mItemFormat);		
			}
			super.drawBackground();
        }
    }
}