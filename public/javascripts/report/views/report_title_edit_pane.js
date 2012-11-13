// ELMO.Report.ReportTitleEditPane < ELMO.Report.EditPane
(function(ns, klass) {

  // constructor
  klass = ns.ReportTitleEditPane = function() {
    this.build()
  };
  
  // inherit from EditPane
  klass.prototype = new ns.EditPane();
  klass.prototype.constructor = klass;
  klass.prototype.parent = ns.EditPane.prototype;
  
  // title
  klass.prototype.title = "Title";
  
  // builds controls
  klass.prototype.build = function() {
    // call super first
    this.parent.build.call(this);
    
    this.title = this.cont.find("input#report_title");
  }
  
  klass.prototype.update = function(report) {
    this.report = report;
    this.title.val(report.attribs.name);
  }

  // extracts data from the view into the model
  klass.prototype.extract = function() {
    this.report.attribs.name = this.title.val();
  }
  
  klass.prototype.fields_for_validation_errors = function() {
    return ["name"];
  }
}(ELMO.Report));