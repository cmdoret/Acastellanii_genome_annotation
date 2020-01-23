Submit-block ::= {
  contact {
    contact {
      name name {
        last "Koszul",
        first "Romain",
        middle "",
        initials "",
        suffix "",
        title ""
      },
      affil std {
        affil "Institut Pasteur",
        div "Department of Genomes and Genetic",
        city "Paris",
        sub "Paris",
        country "France",
        street "28 Rue du Docteur Roux",
        email "romain.koszul@pasteur.fr",
        postal-code "75015"
      }
    }
  },
  cit {
    authors {
      names std {
        {
          name name {
            last "Matthey-Doret",
            first "Cyril",
            middle "",
            initials "",
            suffix "",
            title ""
          }
        }
      },
      affil std {
        affil "Institut Pasteur",
        div "Department of Genomes and Genetic",
        city "Paris",
        sub "Paris",
        country "France",
        street "28 Rue du Docteur Roux",
        postal-code "75015"
      }
    }
  },
  subtype new
}
Seqdesc ::= pub {
  pub {
    gen {
      cit "unpublished",
      authors {
        names std {
          {
            name name {
              last "Matthey-Doret",
              first "Cyril",
              middle "",
              initials "",
              suffix "",
              title ""
            }
          }
        }
      },
      title "Assembly and comparative analysis of two Acanthamoeba castellanii
 strains"
    }
  }
}
Seqdesc ::= user {
  type str "DBLink",
  data {
    {
      label str "BioProject",
      num 1,
      data strs {
        "SUB6793761"
      }
    },
    {
      label str "BioSample",
      num 1,
      data strs {
        "SUB6875876"
      }
    }
  }
}
Seqdesc ::= user {
  type str "Submission",
  data {
    {
      label str "AdditionalComment",
      data str "ALT EMAIL:romain.koszul@pasteur.fr"
    }
  }
}
Seqdesc ::= user {
  type str "Submission",
  data {
    {
      label str "AdditionalComment",
      data str "Submission Title:None"
    }
  }
}
