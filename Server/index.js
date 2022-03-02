const express = require('express')
const app = express()
const server = require('http').createServer(app);
const mongoose = require('mongoose');
const bodyparser = require('body-parser');
const cors = require('cors');

const Contact = require('./models/contact');
const Settings = require('./models/settings');


app.use(bodyparser.json());
app.use(bodyparser.urlencoded({extened: true}));
app.use(cors());
app.options('*', cors());


const port = process.env.PORT || 3000;

mongoose.connect(`mongodb+srv://anmoiotadmin:anmoiotadmin@clusteriot.h9pwp.mongodb.net/vimigo?retryWrites=true`, {useNewUrlParser: true, useUnifiedTopology: true})
.then(() => {
    console.log('Database connection successful');
    server.listen(port, () => console.info(`listening on port ${port}`));
})
.catch(err => {
    console.error('Database connection error: ' + err);
});


app.get('/getcontacts', async (req, res) => {  
    Contact.find({}, {_id:0, __v:0}, (err, result) => { 
        if (err || !result) {
            console.log(err);
            res.json("{}");
        } else {
            console.log("get contacts");
            res.json(result);
        } 
    })
});

app.get('/gettimestamp', async (req, res) => {  
    Settings.findOne({_id: '621e6d14781ddfdb22f02b9f'}, {_id:0, __v:0}, (err, result) => { 
        if (err || !result) {
            console.log(err);
            res.json("{}");
        } else {
            console.log("get timestamp: " + result.timestamp);
            res.json(result.timestamp);
        } 
    })
});

app.post('/addcontacts', async (req, res) => {
    Contact.insertMany(req.body, function(err, data) {
        if(err) {
            console.log(err);
        }else{
            console.log("contacts added");
        } 
    });
});

app.post('/addcontact', async (req, res) => {
    const contact = new Contact({
        user: req.body.user,
        phone: req.body.phone,
        checkin: req.body.checkin,
    });
    contact.save();
});

app.post('/delcontact', async (req, res) => {
    Contact.findOneAndDelete({user: req.body.user, phone: req.body.phone},
     (err) => { 
        if (err) {
            console.log(err);
        } else {
            console.log("deleted contact");
        } 
    })
});


app.post('/settimestamp', async (req, res) => { 
    console.log("set timestamp to: " + req.body.flag);
    Settings.updateOne(
        {_id: '621e6d14781ddfdb22f02b9f' },
        {
            $set: {
                timestamp: req.body.flag,
            }
        },
    function(err, result){
        if(!err){
            console.log("Timestamp set");
        }else{
            console.log("Error: " + err);
        }
    });
});

