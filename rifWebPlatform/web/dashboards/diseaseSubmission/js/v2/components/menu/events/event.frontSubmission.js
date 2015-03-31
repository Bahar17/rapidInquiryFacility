RIF.menu['event-frontSubmission'] = (function(dom, firer) {
   
    
   dom.dropdownInputs.keydown(function(e) {
      if (this.id === 'searchCodeInput') {
         return true;
      };
      return false;
   });
   
   $(dom.dialogClose).click(function() {
      var id = $(this).attr('href');
      $(id).hide();
      if (id === '#statusbar') {
         RIF.statusBar(null, null, -1); 
      };
   });
   
    $('#statusbar').click(function() {
      $(this).hide();
      RIF.statusBar(null, null, -1);   
   });
   
    $(dom.studyArea).click(function() { 
      firer.isDialogReady('areaSelection');    
      $(dom.studyAreaDialog).show();
   });
   
    $(dom.compArea).click(function() { 
      $(dom.compAreaDialog).show();
   });
   
    $(dom.importExportEl).click(function() { 
      $(dom.retrieveDialog).show();
   });    
       
   $(dom.fromFile).click(function() { 
      $(dom.runFromFileModal).show();
   }); 
    
    
    $(dom.invParameters).click(function() { 
      firer.isDialogReady('investigationDialog');
   });
   
    $(dom.logOut).click(function() {
      firer.fire('logOut', null);    
   })
   
   
   dom.studyName.change(function() {
      var val = $(this).val();
      if (val != '') {
         dom.studyName.addClass('inputBorderSelection');
      } else {
         dom.studyName.removeClass('inputBorderSelection');
         val = null;
      };
      firer.studyNameChanged(val);
   });
    
   dom.healthTheme.change(function() {
      var val = $(this).val();
      firer.healthThemeChanged( val);
   });
    
   dom.numerator.change(function() {
      var val = $(this).val();
      firer.numeratorChanged(val);
   });
    
   dom.denominator.change(function() {
      var val = $(this).val();
      firer.denominatorChanged(val);
   });
});