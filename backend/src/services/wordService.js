/**
 * Vocabulary Service
 * Handles business logic for retrieving vocabulary words.
 */

const getMockWords = () => {
  return [
    {
      id: "api-1",
      word: "Serendipity",
      meaning: "Finding something good without looking for it.",
      translation: "Serendipia",
      category: "Nature"
    },
    {
      id: "api-2",
      word: "Petrichor",
      meaning: "The earthy scent produced when rain falls on dry soil.",
      translation: "Petricor",
      category: "Nature"
    },
    {
      id: "api-3",
      word: "Limerence",
      meaning: "The state of being infatuated with another person.",
      translation: "Encaprichamiento",
      category: "Emotion"
    },
    {
      id: "api-4",
      word: "Eloquence",
      meaning: "Fluent or persuasive speaking or writing.",
      translation: "Elocuencia",
      category: "Skill"
    },
    {
      id: "api-5",
      word: "Resilience",
      meaning: "The capacity to recover quickly from difficulties.",
      translation: "Resiliencia",
      category: "Character"
    },
    {
      id: "api-6",
      word: "Ineffable",
      meaning: "Too great or extreme to be expressed or described in words.",
      translation: "Inefable",
      category: "Emotion"
    }
  ];
};

module.exports = {
  getMockWords
};
