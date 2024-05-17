OOOS_BY_WDAY = [nil, nil, ['Lilian', 'Hendrik', 'Marvin', 'Maged', 'Marthe' ], ['Toni'], ['Leonard'], nil, nil]

TASKS_BY_WDAY = [
  { 0 => 'Wochenplan' }, # Sonntag
  { 0 => 'Unterschriftenmappe', # Montag
      1 => 'Trello',
      2 => 'Email-Triage',
      3 => 'Fragen für die Profrunde',
      4 => 'ForschMedi updaten',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Dienstag
      1 => 'Trello',
      2 => 'Email-Triage',
      3 => 'Standup-Notizen (Hendrik, Marthe, Marvin, Maged)',
      4 => 'SMNF Folien',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Mittwoch
      1 => 'Trello',
      2 => 'Email-Triage',
      3 => 'OSE check',
      4 => 'Standup-Notizen (Toni)',
      5 =>  'Jour-Fixe Agenda',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Donnerstag
      1 => 'Trello',
      2 => 'Email-Triage',
      3 => 'Standup-Notizen (Leonard, Lilian)',
      4 => 'SMNF updaten',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Freitag
      1 => 'Trello',
      2 => 'Email-Triage',
      14 => 'Unterschriften Mappe wegsortieren',
      15 => 'Emails',
      16 => 'Week-Shutdown',
      17 => 'Nächste Woche drucken'},
  { 0 => 'Sport' },
]


APPOINTMENTS_BY_WDAY = [
  {},
  # Montag
  {9 => 'Diss-Updates', 10 => 'Diss-Updates', 14 => 'ForschMedi', 15 => 'ForschMedi', 16 => 'Profrunde', 17 => 'Profrunde'}, # Monday
  {10 => 'OOO Jork Milde', 12 => 'OOO Lilian', 13 => 'OOO Hendrik', 14 => 'OOO Marthe', 16 => 'OOO Marvin & Maged'},
  {10 => 'SMNF', 11 => 'SMNF', 12 => 'OSE', 13 => 'OSE', 14 => 'OOO Toni', 16 => 'JourFixe'}, # Wednesday
  {11 => 'OOO Leonard', 14 => 'Coffe Break', 15 => 'OOO Lilian'},
  {11 => 'Diss-Sprechstunde', 13 => 'Lehre-Prep', 16 => 'Wrapup'}, # Friday
  {},
]
