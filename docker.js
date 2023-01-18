require('livescript');
require('dotenv').config()
const cron = require('node-cron');
const generator = require('./srv/generator');

cron.schedule('17 * * * *', () => {
    generator.warmup();
});
  

cron.schedule('41 11 * * *', () => {
    generator.warmup(generator.oldSeasons());
});

console.log(new Date(), 'starting')
generator.warmup();
generator.warmup(generator.oldSeasons());
