const mongoose = require('mongoose');
const ASchema = mongoose.Schema;

const contactSchema = new ASchema({
    name: 
    {
        type: String,
        required: true,
    },
    phone: 
    {
        type: String,
        required: true,
    },
    checkin: 
    {
        type: String,
        required: true,
    }
});


const contact = mongoose.model('contact', contactSchema);
module.exports = contact;