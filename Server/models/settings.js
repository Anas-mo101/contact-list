const mongoose = require('mongoose');
const ASchema = mongoose.Schema;

const settingsSchema = new ASchema({
    timestamp: 
    {
        type: Boolean,
        required: true,
    }
});


const setting = mongoose.model('setting', settingsSchema);
module.exports = setting;