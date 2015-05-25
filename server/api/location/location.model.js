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
  loadRecent: function(cb) {
    this.find({})
      .populate({path:'author', select: 'name'})
      .exec(cb);
    }
};
module.exports = mongoose.model('Location', LocationSchema);