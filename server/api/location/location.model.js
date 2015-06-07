'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var LocationSchema = new Schema({
  content: {},
  author: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  }
});
LocationSchema.statics = {
  loadRecent: function(autherEmail,cb) {
    this.find({"content.email":autherEmail})
      .populate({path:'author', select: 'name'})
      .exec(cb);
    },
  findAutherFields:function(cb) {

  }
};

module.exports = mongoose.model('Location', LocationSchema);