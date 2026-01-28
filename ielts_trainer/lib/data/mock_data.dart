import '../models/question.dart';

// ================= LISTENING SECTIONS (1-40) =================

// --- PART 1 (Questions 1-10) ---
final TestData listeningPart1 = TestData(
  type: 'Listening',
  title: 'Listening Part 1: Transport Survey',
  audioPath: 'listening1_part1.mp3',
  contentText: 'Listen to the audio and complete the notes below.',
  questions: [
    Question(
      id: 1,
      text: "Name: Luisa ...",
      isInput: true,
      correctTextAnswer: "Hardie",
    ),
    Question(
      id: 2,
      text: "Address: ... White Stone Rd",
      isInput: true,
      correctTextAnswer: "19",
    ),
    Question(
      id: 3,
      text: "Postcode: ...",
      isInput: true,
      correctTextAnswer: "GT8 2LC",
    ),
    Question(
      id: 4,
      text: "Occupation: ...",
      isInput: true,
      correctTextAnswer: "hairdresser",
    ),
    Question(
      id: 5,
      text: "Reason for visit: to go to the ...",
      isInput: true,
      correctTextAnswer: "dentist",
    ),
    Question(
      id: 6,
      text: "Suggestion: better ...",
      isInput: true,
      correctTextAnswer: "lighting",
    ),
    Question(
      id: 7,
      text: "Suggestion: more frequent ...",
      isInput: true,
      correctTextAnswer: "trains",
    ),
    Question(
      id: 8,
      text: "Cycling: having ... parking places",
      isInput: true,
      correctTextAnswer: "safe",
    ),
    Question(
      id: 9,
      text: "Cycling: being able to use a ...",
      isInput: true,
      correctTextAnswer: "shower",
    ),
    Question(
      id: 10,
      text: "Cycling: having cycling ... on busy roads",
      isInput: true,
      correctTextAnswer: "training",
    ),
  ],
);

// --- PART 2 (Questions 11-20) ---
final TestData listeningPart2 = TestData(
  type: 'Listening',
  title: 'Listening Part 2: New City Developments',
  audioPath: 'listening1_part2.mp3',
  contentText: 'Listen and choose the correct letter A, B or C.',
  questions: [
    Question(
      id: 11,
      text: "The idea for the two new developments came from...",
      options: ["local people", "the City Council", "the SWRDC"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 12,
      text: "What is unusual about Brackenside pool?",
      options: ["architectural style", "heating system", "water treatment"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 13,
      text: "Local newspapers have raised worries about...",
      options: [
        "late opening date",
        "cost of the project",
        "size of the facilities",
      ],
      correctOptionIndex: 2,
    ),
    Question(
      id: 14,
      text: "What decision has not yet been made?",
      options: ["whose statue", "opening times", "who will open it"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 15,
      text: "Playground Feature: Asia",
      options: [
        "ancient forts",
        "waterways",
        "ice and snow",
        "jewels",
        "local animals",
        "mountains",
        "music/film",
        "space travel",
        "volcanoes",
      ],
      correctOptionIndex: 4,
    ),
    Question(
      id: 16,
      text: "Playground Feature: Antarctica",
      options: [
        "ancient forts",
        "waterways",
        "ice and snow",
        "jewels",
        "local animals",
        "mountains",
        "music/film",
        "space travel",
        "volcanoes",
      ],
      correctOptionIndex: 5,
    ),
    Question(
      id: 17,
      text: "Playground Feature: South America",
      options: [
        "ancient forts",
        "waterways",
        "ice and snow",
        "jewels",
        "local animals",
        "mountains",
        "music/film",
        "space travel",
        "volcanoes",
      ],
      correctOptionIndex: 3,
    ),
    Question(
      id: 18,
      text: "Playground Feature: North America",
      options: [
        "ancient forts",
        "waterways",
        "ice and snow",
        "jewels",
        "local animals",
        "mountains",
        "music/film",
        "space travel",
        "volcanoes",
      ],
      correctOptionIndex: 7,
    ),
    Question(
      id: 19,
      text: "Playground Feature: Europe",
      options: [
        "ancient forts",
        "waterways",
        "ice and snow",
        "jewels",
        "local animals",
        "mountains",
        "music/film",
        "space travel",
        "volcanoes",
      ],
      correctOptionIndex: 0,
    ),
    Question(
      id: 20,
      text: "Playground Feature: Africa",
      options: [
        "ancient forts",
        "waterways",
        "ice and snow",
        "jewels",
        "local animals",
        "mountains",
        "music/film",
        "space travel",
        "volcanoes",
      ],
      correctOptionIndex: 1,
    ),
  ],
);

// --- PART 3 (Questions 21-30) ---
final TestData listeningPart3 = TestData(
  type: 'Listening',
  title: 'Listening Part 3: Thor Heyerdahl',
  audioPath: 'listening1_part3.mp3',
  contentText: 'Listen and answer the questions.',
  questions: [
    Question(
      id: 21,
      text: "Which hobby was Thor interested in? (1)",
      options: ["camping", "climbing", "collecting", "hunting", "reading"],
      correctOptionIndex: 1,
    ),
    Question(
      id: 22,
      text: "Which hobby was Thor interested in? (2)",
      options: ["camping", "climbing", "collecting", "hunting", "reading"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 23,
      text: "Reason he went to live on an island? (1)",
      options: [
        "ancient carvings",
        "isolated place",
        "new theory",
        "survival skills",
        "extreme environment",
      ],
      correctOptionIndex: 1,
    ),
    Question(
      id: 24,
      text: "Reason he went to live on an island? (2)",
      options: [
        "ancient carvings",
        "isolated place",
        "new theory",
        "survival skills",
        "extreme environment",
      ],
      correctOptionIndex: 4,
    ),
    Question(
      id: 25,
      text: "Academics thought migration was impossible due to...",
      options: ["distance", "lack of materials", "winds and currents"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 26,
      text: "Main reason for raft journey?",
      options: ["overcome setback", "personal quality", "test a theory"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 27,
      text: "Most important aspect of journey?",
      options: ["being first", "speed", "authentic methods"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 28,
      text: "Why did he go to Easter Island?",
      options: ["build statue", "sail reed boat", "learn language"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 29,
      text: "Greatest influence was on...",
      options: [
        "Polynesian origins",
        "archaeological methodology",
        "establishing subject",
      ],
      correctOptionIndex: 1,
    ),
    Question(
      id: 30,
      text: "Criticism of Oliver's textbook?",
      options: [
        "style out of date",
        "content simplified",
        "methodology flawed",
      ],
      correctOptionIndex: 0,
    ),
  ],
);

// --- PART 4 (Questions 31-40) ---
final TestData listeningPart4 = TestData(
  type: 'Listening',
  title: 'Listening Part 4: Future of Management',
  audioPath: 'listening1_part4.mp3',
  contentText: 'Complete the notes below.',
  questions: [
    Question(
      id: 31,
      text: "Business markets: greater ... among companies",
      isInput: true,
      correctTextAnswer: "competition",
    ),
    Question(
      id: 32,
      text: "Increase in power of large ... Companies",
      isInput: true,
      correctTextAnswer: "global",
    ),
    Question(
      id: 33,
      text: "Rising ... in certain countries",
      isInput: true,
      correctTextAnswer: "demand",
    ),
    Question(
      id: 34,
      text: "More discussion with ... before decisions",
      isInput: true,
      correctTextAnswer: "customers",
    ),
    Question(
      id: 35,
      text: "Environmental concerns lead to more ...",
      isInput: true,
      correctTextAnswer: "regulation",
    ),
    Question(
      id: 36,
      text: "Teams formed to work on a particular ...",
      isInput: true,
      correctTextAnswer: "project",
    ),
    Question(
      id: 37,
      text: "Offer hours that are ...",
      isInput: true,
      correctTextAnswer: "flexible",
    ),
    Question(
      id: 38,
      text: "Need for managers to provide good ...",
      isInput: true,
      correctTextAnswer: "leadership",
    ),
    Question(
      id: 39,
      text: "Changes influenced by ... taking senior roles",
      isInput: true,
      correctTextAnswer: "women",
    ),
    Question(
      id: 40,
      text: "More and more ... workers",
      isInput: true,
      correctTextAnswer: "self-employed",
    ),
  ],
);

// ================= READING SECTIONS (1-40) =================

// PASSAGE 1
final TestData readingPart1 = TestData(
  type: 'Reading',
  title: 'Reading Passage 1: Making Time for Science',
  contentText: '''
Chronobiology might sound a little futuristic - like something from a science fiction novel, perhaps - but it's actually a field of study that concerns one of the oldest processes life on this planet has ever known: short-term rhythms of time and their effect on flora and fauna.

This can take many forms. Marine life, for example, is influenced by tidal patterns. Animals tend to be active or inactive depending on the position of the sun or moon. Numerous creatures, humans included, are largely diurnal - that is, they like to come out during the hours of sunlight. Nocturnal animals, such as bats and possums, prefer to forage by night. A third group are known as crepuscular: they thrive in the low-light of dawn and dusk and remain inactive at other hours.

When it comes to humans, chronobiologists are interested in what is known as the circadian rhythm. This is the complete cycle our bodies are naturally geared to undergo within the passage of a twenty-four hour day. Aside from sleeping at night and waking during the day, each cycle involves many other factors such as changes in blood pressure and body temperature. Not everyone has an identical circadian rhythm. 'Night people', for example, often describe how they find it very hard to operate during the morning, but become alert and focused by evening. This is a benign variation within circadian rhythms known as a chronotype.

Scientists have limited abilities to create durable modifications of chronobiological demands. Recent therapeutic developments for humans such as artificial light machines and melatonin administration can reset our circadian rhythms, for example, but our bodies can tell the difference and health suffers when we breach these natural rhythms for extended periods of time. Plants appear no more malleable in this respect; studies demonstrate that vegetables grown in season and ripened on the tree are far higher in essential nutrients than those grown in greenhouses and ripened by laser.

Knowledge of chronobiological patterns can have many pragmatic implications for our day-to-day lives. While contemporary living can sometimes appear to subjugate biology - after all, who needs circadian rhythms when we have caffeine pills, energy drinks, shift work and cities that never sleep? - keeping in synch with our body clock is important.

The average urban resident, for example, rouses at the eye-blearing time of 6.04 a.m., which researchers believe to be far too early. One study found that even rising at 7.00 a.m. has deleterious effects on health unless exercise is performed for 30 minutes afterward. The optimum moment has been whittled down to 7.22 a.m.; muscle aches, headaches and moodiness were reported to be lowest by participants in the study who awoke then.

Once you're up and ready to go, what then? If you're trying to shed some extra pounds, dieticians are adamant: never skip breakfast. This disorients your circadian rhythm and puts your body in starvation mode. The recommended course of action is to follow an intense workout with a carbohydrate-rich breakfast; the other way round and weight loss results are not as pronounced.

Morning is also great for breaking out the vitamins. Supplement absorption by the body is not temporal-dependent, but naturopath Pam Stone notes that the extra boost at breakfast helps us get energised for the day ahead. For improved absorption, Stone suggests pairing supplements with a food in which they are soluble and steering clear of caffeinated beverages. Finally, Stone warns to take care with storage; high potency is best for absorption, and warmth and humidity are known to deplete the potency of a supplement.

After-dinner espressos are becoming more of a tradition - we have the Italians to thank for that - but to prepare for a good night's sleep we are better off putting the brakes on caffeine consumption as early as 3 p.m. With a seven hour half-life, a cup of coffee containing 90 mg of caffeine taken at this hour could still leave 45 mg of caffeine in your nervous system at ten o'clock that evening. It is essential that, by the time you are ready to sleep, your body is rid of all traces.

Evenings are important for winding down before sleep; however, dietician Geraldine Georgeou warns that an after-five carbohydrate-fast is more cultural myth than chronobiological demand. This will deprive your body of vital energy needs. Overloading your gut could lead to indigestion, though. Our digestive tracts do not shut down for the night entirely, but their work slows to a crawl as our bodies prepare for sleep. Consuming a modest snack should be entirely sufficient.
  ''',
  questions: [
    Question(
      id: 1,
      text:
          "Chronobiology is the study of how living things have evolved over time.",
      options: ["TRUE", "FALSE", "NOT GIVEN"],
      correctOptionIndex: 1,
    ),
    Question(
      id: 2,
      text: "The rise and fall of sea levels affects how sea creatures behave.",
      options: ["TRUE", "FALSE", "NOT GIVEN"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 3,
      text: "Most animals are active during the daytime.",
      options: ["TRUE", "FALSE", "NOT GIVEN"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 4,
      text:
          "Circadian rhythms identify how we do different things on different days.",
      options: ["TRUE", "FALSE", "NOT GIVEN"],
      correctOptionIndex: 1,
    ),
    Question(
      id: 5,
      text: "A 'night person' can still have a healthy circadian rhythm.",
      options: ["TRUE", "FALSE", "NOT GIVEN"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 6,
      text:
          "New therapies can permanently change circadian rhythms without causing harm.",
      options: ["TRUE", "FALSE", "NOT GIVEN"],
      correctOptionIndex: 1,
    ),
    Question(
      id: 7,
      text: "Naturally-produced vegetables have more nutritional value.",
      options: ["TRUE", "FALSE", "NOT GIVEN"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 8,
      text:
          "What did researchers identify as the ideal time to wake up in the morning?",
      options: ["6.04", "7.00", "7.22", "7.30"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 9,
      text: "In order to lose weight, we should ...",
      options: [
        "avoid eating breakfast",
        "eat a low carbohydrate breakfast",
        "exercise before breakfast",
        "exercise after breakfast",
      ],
      correctOptionIndex: 2,
    ),
    Question(
      id: 10,
      text: "Which is NOT mentioned as a way to improve supplement absorption?",
      options: [
        "avoiding drinks containing caffeine",
        "taking supplements at breakfast",
        "taking supplements with soluble foods",
        "storing supplements in a cool, dry environment",
      ],
      correctOptionIndex: 1,
    ),
    Question(
      id: 11,
      text: "The best time to stop drinking coffee is ...",
      options: [
        "mid-afternoon",
        "10 p.m.",
        "only when feeling anxious",
        "after dinner",
      ],
      correctOptionIndex: 0,
    ),
    Question(
      id: 12,
      text: "In the evening, we should",
      options: [
        "stay away from carbohydrates",
        "stop exercising",
        "eat as much as possible",
        "eat a light meal",
      ],
      correctOptionIndex: 3,
    ),
    Question(
      id: 13,
      text: "Which best describes the main aim of Reading Passage 1?",
      options: [
        "to suggest healthier ways",
        "to describe how modern life made chronobiology irrelevant",
        "to introduce chronobiology and describe applications",
        "to plan a daily schedule",
      ],
      correctOptionIndex: 2,
    ),
  ],
);

// PASSAGE 2
final TestData readingPart2 = TestData(
  type: 'Reading',
  title: 'Reading Passage 2: The Triune Brain',
  contentText: '''
The first of our three brains to evolve is what scientists call the reptilian cortex. This brain sustains the elementary activities of animal survival such as respiration, adequate rest and a beating heart. We are not required to consciously "think" about these activities. The reptilian cortex also houses the "startle centre", a mechanism that facilitates swift reactions to unexpected occurrences in our surroundings. That panicked lurch you experience when a door slams shut somewhere in the house, or the heightened awareness you feel when a twig cracks in a nearby bush while out on an evening stroll are both examples of the reptilian cortex at work.

When it comes to our interaction with others, the reptilian brain offers up only the most basic impulses: aggression, mating, and territorial defence. There is no great difference, in this sense, between a crocodile defending its spot along the river and a turf war between two urban gangs. Although the lizard may stake a claim to its habitat, it exerts total indifference toward the well-being of its young.

Listen to the anguished squeal of a dolphin separated from its pod or witness the sight of elephants mourning their dead, however, and it is clear that a new development is at play. Scientists have identified this as the limbic cortex. Unique to mammals, the limbic cortex impels creatures to nurture their offspring by delivering feelings of tenderness and warmth to the parent when children are nearby. These same sensations also cause mammals to develop various types of social relations and kinship networks. When we are with others of "our kind" - be it at soccer practice, church, school or a nightclub - we experience positive sensations of togetherness, solidarity and comfort. If we spend too long away from these networks, then loneliness sets in and encourages us to seek companionship.

Only human capabilities extend far beyond the scope of these two cortexes. Humans eat, sleep and play, but we also speak, plot, rationalise and debate finer points of morality. Our unique abilities are the result of an expansive third brain - the neocortex - which engages with logic, reason and ideas. The power of the neocortex comes from its ability to think beyond the present, concrete moment. While other mammals are mainly restricted to impulsive actions (although some, such as apes, can learn and remember simple lessons), humans can think about the "big picture". We can string together simple lessons (for example, an apple drops downwards from a tree; hurting others causes unhappiness) to develop complex theories of physical or social phenomena (such as the laws of gravity and a concern for human rights).

The neocortex is also responsible for the process by which we decide on and commit to particular courses of action. Strung together over time, these choices can accumulate into feats of progress unknown to other animals. Anticipating a better grade on the following morning's exam, a student can ignore the limbic urge to socialise and go to sleep early instead. Over three years, this ongoing sacrifice translates into a first class degree and a scholarship to graduate school; over a lifetime, it can mean ground-breaking contributions to human knowledge and development. The ability to sacrifice our drive for immediate satisfaction in order to benefit later is a product of the neocortex.

Understanding the triune brain can help us appreciate the different natures of brain damage and psychological disorders. The most devastating form of brain damage, for example, is a condition in which someone is understood to be brain dead. In this state a person appears merely unconscious - sleeping, perhaps - but this is illusory. Here, the reptilian brain is functioning on autopilot despite the permanent loss of other cortexes.

Disturbances to the limbic cortex are registered in a different manner. Pups with limbic damage can move around and feed themselves well enough but do not register the presence of their litter mates. Scientists have observed how, after a limbic lobotomy "one impaired monkey stepped on his outraged peers as if treading on a log or a rock". In our own species, limbic damage is closely related to sociopathic behaviour. Sociopaths in possession of fully-functioning neocortexes are often shrewd and emotionally intelligent people but lack any ability to relate to, empathise with or express concern for others.

One of the neurological wonders of history occurred when a railway worker named Phineas Gage survived an incident during which a metal rod skewered his skull, taking a considerable amount of his neocortex with it. Though Gage continued to live and work as before, his fellow employees observed a shift in the equilibrium of his personality. Gage's animal propensities were now sharply pronounced while his intellectual abilities suffered; garrulous or obscene jokes replaced his once quick wit. New findings suggest, however, that Gage managed to soften these abrupt changes over time and rediscover an appropriate social manner. This would indicate that reparative therapy has the potential to help patients with advanced brain trauma to gain an improved quality of life.
  ''',
  questions: [
    Question(
      id: 14,
      text: "Giving up short-term happiness for future gains",
      options: ["The reptilian cortex", "The limbic cortex", "The neocortex"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 15,
      text: "Maintaining the bodily functions necessary for life",
      options: ["The reptilian cortex", "The limbic cortex", "The neocortex"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 16,
      text: "Experiencing the pain of losing another",
      options: ["The reptilian cortex", "The limbic cortex", "The neocortex"],
      correctOptionIndex: 1,
    ),
    Question(
      id: 17,
      text: "Forming communities and social groups",
      options: ["The reptilian cortex", "The limbic cortex", "The neocortex"],
      correctOptionIndex: 1,
    ),
    Question(
      id: 18,
      text: "Making a decision and carrying it out",
      options: ["The reptilian cortex", "The limbic cortex", "The neocortex"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 19,
      text: "Guarding areas of land",
      options: ["The reptilian cortex", "The limbic cortex", "The neocortex"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 20,
      text: "Developing explanations for things",
      options: ["The reptilian cortex", "The limbic cortex", "The neocortex"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 21,
      text: "Looking after one's young",
      options: ["The reptilian cortex", "The limbic cortex", "The neocortex"],
      correctOptionIndex: 1,
    ),
    Question(
      id: 22,
      text: "Responding quickly to sudden movement and noise",
      options: ["The reptilian cortex", "The limbic cortex", "The neocortex"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 23,
      text: "A person with only a functioning reptilian cortex is known as...",
      isInput: true,
      correctTextAnswer: "brain dead",
    ),
    Question(
      id: 24,
      text: "...in humans is associated with limbic disruption.",
      isInput: true,
      correctTextAnswer: "sociopathic behaviour",
    ),
    Question(
      id: 25,
      text: "An industrial accident caused Phineas Gage to lose part of his...",
      isInput: true,
      correctTextAnswer: "neocortex",
    ),
    Question(
      id: 26,
      text:
          "After his accident, co-workers noticed an imbalance between Gage's ... and higher-order thinking.",
      isInput: true,
      correctTextAnswer: "animal propensities",
    ),
  ],
);

// PASSAGE 3
final TestData readingPart3 = TestData(
  type: 'Reading',
  title: 'Reading Passage 3: Helium\'s Future Up in the Air',
  contentText: '''
[A] In recent years we have all been exposed to dire media reports concerning the impending demise of global coal and oil reserves, but the depletion of another key non-renewable resource continues without receiving much press at all. Helium - an inert, odourless, monatomic element known to lay people as the substance that makes balloons float and voices squeak when inhaled - could be gone from this planet within a generation.

[B] Helium itself is not rare; there is actually a plentiful supply of it in the cosmos. In fact, 24 per cent of our galaxy's elemental mass consists of helium, which makes it the second most abundant element in our universe. Because of its lightness, however, most helium vanished from our own planet many years ago. Consequently, only a miniscule proportion – 0.00052%, to be exact – remains in earth's atmosphere. Helium is the by-product of millennia of radioactive decay from the elements thorium and uranium. The helium is mostly trapped in subterranean natural gas bunkers and commercially extracted through a method known as fractional distillation.

[C] The loss of helium on Earth would affect society greatly. Defying the perception of it as a novelty substance for parties and gimmicks, the element actually has many vital applications in society. Probably the most well known commercial usage is in airships and blimps (non-flammable helium replaced hydrogen as the lifting gas du jour after the Hindenburg catastrophe in 1932, during which an airship burst into flames and crashed to the ground killing some passengers and crew). But helium is also instrumental in deep-sea diving, where it is blended with nitrogen to mitigate the dangers of inhaling ordinary air under high pressure; as a cleaning agent for rocket engines; and, in its most prevalent use, as a coolant for superconducting magnets in hospital MRI (magnetic resonance imaging) scanners.

[D] The possibility of losing helium forever poses the threat of a real crisis because its unique qualities are extraordinarily difficult, if not impossible to duplicate (certainly, no biosynthetic ersatz product is close to approaching the point of feasibility for helium, even as similar developments continue apace for oil and coal). Helium is even cheerfully derided as a "loner" element since it does not adhere to other molecules like its cousin, hydrogen. According to Dr. Lee Sobotka, helium is the "most noble of gases, meaning it's very stable and non-reactive for the most part (...) it has a closed electronic configuration, a very tightly bound atom. It is this coveting of its own electrons that prevents combination with other elements". Another important attribute is helium's unique boiling point, which is lower than that for any other element. The worsening global shortage could render millions of dollars of high-value, life-saving equipment totally useless. The dwindling supplies have already resulted in the postponement of research and development projects in physics laboratories and manufacturing plants around the world. There is an enormous supply and demand imbalance partly brought about by the expansion of high-tech manufacturing in Asia.

[E] The source of the problem is the Helium Privatisation Act (HPA), an American law passed in 1996 that requires the U.S. National Helium Reserve to liquidate its helium assets by 2015 regardless of the market price. Although intended to settle the original cost of the reserve by a U.S. Congress ignorant of its ramifications, the result of this fire sale is that global helium prices are so artificially deflated that few can be bothered recycling the substance or using it judiciously. Deflated values also mean that natural gas extractors see no reason to capture helium. Much is lost in the process of extraction. As Sobotka notes: "[t]he government had the good vision to store helium, and the question now is: Will the corporations have the vision to capture it when extracting natural gas, and consumers the wisdom to recycle? This takes long-term vision because present market forces are not sufficient to compel prudent practice".

[F] A number of steps need to be taken in order to avert a costly predicament in the coming decades. Firstly, all existing supplies of helium ought to be conserved and released only by permit, with medical uses receiving precedence over other commercial or recreational demands. Secondly, conservation should be obligatory and enforced by a regulatory agency. At the moment some users, such as hospitals, tend to recycle diligently while others, such as NASA, squander massive amounts of helium. Lastly, research into alternatives to helium must begin in earnest.
  ''',
  questions: [
    Question(
      id: 27,
      text: "A use for helium which makes an activity safer (Paragraph Letter)",
      options: ["A", "B", "C", "D", "E", "F"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 28,
      text:
          "The possibility of creating an alternative to helium (Paragraph Letter)",
      options: ["A", "B", "C", "D", "E", "F"],
      correctOptionIndex: 3,
    ),
    Question(
      id: 29,
      text:
          "A term which describes the process of how helium is taken out of the ground (Paragraph Letter)",
      options: ["A", "B", "C", "D", "E", "F"],
      correctOptionIndex: 1,
    ),
    Question(
      id: 30,
      text:
          "A reason why users of helium do not make efforts to conserve it (Paragraph Letter)",
      options: ["A", "B", "C", "D", "E", "F"],
      correctOptionIndex: 4,
    ),
    Question(
      id: 31,
      text:
          "A contrast between helium's chemical properties and how non-scientists think about it (Paragraph Letter)",
      options: ["A", "B", "C", "D", "E", "F"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 32,
      text: "Helium chooses to be on its own.",
      options: ["YES", "NO", "NOT GIVEN"],
      correctOptionIndex: 0,
    ),
    Question(
      id: 33,
      text: "Helium is a very cold substance.",
      options: ["YES", "NO", "NOT GIVEN"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 34,
      text:
          "High-tech industries in Asia use more helium than laboratories and manufacturers in other parts of the world.",
      options: ["YES", "NO", "NOT GIVEN"],
      correctOptionIndex: 2,
    ),
    Question(
      id: 35,
      text: "The US Congress understood the possible consequences of the HPA.",
      options: ["YES", "NO", "NOT GIVEN"],
      correctOptionIndex: 1,
    ),
    Question(
      id: 36,
      text:
          "...because ... will not be encouraged through buying and selling alone.",
      isInput: true,
      correctTextAnswer: "prudent practice",
    ),
    Question(
      id: 37,
      text: "Richardson believes that the ... needs to be withdrawn",
      isInput: true,
      correctTextAnswer: "privatisation policy",
    ),
    Question(
      id: 38,
      text:
          "He argues that higher costs would mean people have ... to use the resource many times over.",
      isInput: true,
      correctTextAnswer: "incentives",
    ),
    Question(
      id: 39,
      text: "People should need a ... to access helium that we still have.",
      isInput: true,
      correctTextAnswer: "permit",
    ),
    Question(
      id: 40,
      text: "Furthermore, a ... should ensure that helium is used carefully.",
      isInput: true,
      correctTextAnswer: "regulatory agency",
    ),
  ],
);

// ================= SPEAKING SECTION =================

final TestData speakingPart1 = TestData(
  type: 'Speaking',
  title: 'Speaking Part 1',
  contentText:
      'PART 1: INTRODUCTION\n\n"Let\'s talk about your hometown. Is it a big city or a small town? What do you like most about living there?"\n\n(Answer length: 20-40 seconds)',
  questions: [],
);

final TestData speakingPart2 = TestData(
  type: 'Speaking',
  title: 'Speaking Part 2',
  contentText:
      'PART 2: CUE CARD\n\nDescribe a website that you often use.\n\nYou should say:\n- What type of website it is\n- How you found out about it\n- What it looks like\nAnd explain why you find it useful.\n\n(Speak for 1-2 minutes)',
  questions: [],
);

final TestData speakingPart3 = TestData(
  type: 'Speaking',
  title: 'Speaking Part 3',
  contentText:
      'PART 3: DISCUSSION\n\n"How has the internet changed the way people communicate? Do you think children spend too much time online? What about privacy?"\n\n(Answer length: 40-60 seconds)',
  questions: [],
);

// ================= WRITING SECTIONS =================

final TestData writingTask1 = TestData(
  type: 'Writing',
  title: 'Writing Task 1: Recycling Stats',
  contentText:
      'The graph below shows the proportion of four different materials that were recycled from 1982 to 2010 in a particular country.\n\nSummarise the information by selecting and reporting the main features, and make comparisons where relevant.\n\n(Write at least 150 words)',
  imagePath: 'writing1_part1.png',
  questions: [],
);

final TestData writingTask2 = TestData(
  type: 'Writing',
  title: 'Writing Task 2: Opinion Essay',
  contentText:
      'Write about the following topic:\n\nLearning English at school is often seen as more important than learning local languages. If these are not taught, many are at risk of dying out.\n\nIn your opinion, is it important for everyone to learn English? Should we try to ensure the survival of local languages and, if so, how?\n\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.\n\n(Write at least 250 words)',
  questions: [],
);

// --- ГЛАВНЫЙ СПИСОК ТЕСТОВ ---
final List<TestData> allTests = [
  listeningPart1,
  readingPart1,
  writingTask1,
  speakingPart1,
];

// Функция поиска
TestData getTestByName(String type) {
  // Listening
  if (type.contains('Listening')) {
    if (type.contains('Part 1')) return listeningPart1;
    if (type.contains('Part 2')) return listeningPart2;
    if (type.contains('Part 3')) return listeningPart3;
    if (type.contains('Part 4')) return listeningPart4;
    return listeningPart1;
  }

  // Reading
  if (type.contains('Reading')) {
    if (type.contains('Part 1')) return readingPart1;
    if (type.contains('Part 2')) return readingPart2;
    if (type.contains('Part 3')) return readingPart3;
    return readingPart1;
  }

  // Writing
  if (type == 'Writing Task 1') return writingTask1;
  if (type == 'Writing Task 2') return writingTask2;

  // Speaking
  if (type == 'Speaking Part 1' || type == 'Speaking') return speakingPart1;
  if (type == 'Speaking Part 2') return speakingPart2;
  if (type == 'Speaking Part 3') return speakingPart3;

  return allTests[0];
}
