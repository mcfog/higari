require('livescript');

generator = require('./srv/generator');

generator.warmup(generator.oldSeasons());
