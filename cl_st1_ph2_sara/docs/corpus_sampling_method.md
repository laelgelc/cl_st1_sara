# Corpus Sampling Method

The final human-authored corpus was constructed using a two-stage length-controlled and author-balanced sampling procedure aimed to select approximately 1000 short stories.

First, short stories were restricted to those whose word counts fell within the interquartile range (IQR) of the full word-count distribution ([Table 1](#table-1)), corresponding to the range between 1913 and 5540 words.

<a id="table-1"></a>

**Table 1. Descriptive statistics for word count**

| Statistic |       Value |
|-----------|------------:|
| count     | 4091.000000 |
| mean      | 3492.209240 |
| std       | 1892.213846 |
| min       |   21.000000 |
| 25%       | 1913.000000 |
| 50%       | 3456.000000 |
| 75%       | 5540.000000 |
| max       | 6527.000000 |

**Variable:** `word_count`  
**dtype:** `float64`

[Table 2](#table-2) depicts the authors and their respective number of stories that fall within the IQR, or 2045. This IQR-based restriction was used as a method for reducing length-related heterogeneity, since word count can influence many corpus-linguistic measures and the distribution of literary text lengths is unlikely to be normal. The IQR provides a non-parametric measure of central spread and limits the influence of unusually short or long texts.

<a id="table-2"></a>

**Table 2. Authors and number of short stories within the IQR**

| Author                      |    Count |
|-----------------------------|---------:|
| O Henry                     |      183 |
| W W Jacobs                  |      136 |
| Guy De Maupassant           |      102 |
| Jack London                 |       94 |
| Rudyard Kipling             |       84 |
| Nathaniel Hawthorne         |       54 |
| Mark Twain                  |       49 |
| Ambrose Bierce              |       45 |
| Ts Arthur                   |       43 |
| William Dean Howells        |       43 |
| Edgar Allan Poe             |       41 |
| Charles Dickens             |       38 |
| H P Lovecraft               |       38 |
| Kate Chopin                 |       37 |
| Henry Van Dyke              |       31 |
| Hh Munro Saki               |       31 |
| Mary E Wilkins Freeman      |       31 |
| Robert Barr                 |       31 |
| Hg Wells                    |       29 |
| Charlotte M Yonge           |       28 |
| P G Wodehouse               |       27 |
| L Frank Baum                |       26 |
| Hans Christian Andersen     |       25 |
| Jerome K Jerome             |       25 |
| Katherine Mansfield         |       24 |
| Bret Harte                  |       23 |
| Honore De Balzac            |       22 |
| Lucy Maud Montgomery        |       22 |
| Harriet Beecher Stowe       |       21 |
| Henry Lawson                |       20 |
| Arnold Bennett              |       19 |
| Ralph Henry Barbour         |       19 |
| Leo Tolstoy                 |       15 |
| Rabindranath Tagore         |       15 |
| Arthur Quiller Couch        |       14 |
| Melville Davisson Post      |       14 |
| Washington Irving           |       14 |
| Edna Ferber                 |       13 |
| Joseph Sheridan Le Fanu     |       13 |
| Louisa May Alcott           |       13 |
| Wc Morrow                   |       13 |
| Aleksandr I Kuprin          |       12 |
| Algernon Blackwood          |       12 |
| Herman Melville             |       12 |
| James Joyce                 |       12 |
| Stewart Edward White        |       12 |
| Ellis Parker Butler         |       11 |
| Stephen Crane               |       11 |
| Elia W Peattie              |       10 |
| Mary Roberts Rinehart       |       10 |
| Richard Connell             |       10 |
| William Butler Yeats        |       10 |
| Zane Grey                   |       10 |
| Andy Adams                  |        9 |
| Mr James                    |        9 |
| Rex Ellingwood Beach        |        9 |
| Sherwood Anderson           |        9 |
| Susan Glaspell              |        9 |
| Bram Stoker                 |        8 |
| D H Lawrence                |        8 |
| Edith Wharton               |        8 |
| Frank Stockton              |        8 |
| Maxim Gorky                 |        8 |
| Willa Cather                |        8 |
| Frank Norris                |        7 |
| George Gissing              |        7 |
| Harriet Prescott Spofford   |        7 |
| Oscar Wilde                 |        7 |
| Sarah Orne Jewett           |        7 |
| Walter Mcroberts            |        7 |
| Alexsander Pushkin          |        6 |
| Alice Dunbar Nelson         |        6 |
| Laura E Richards            |        6 |
| Philip K Dick               |        6 |
| Chimamanda Ngozi Adichie    |        5 |
| Ethel M Dell                |        5 |
| Franz Kafka                 |        5 |
| George Saunders             |        5 |
| Jhumpa Lahiri               |        5 |
| Nana Kwame Adjei-Brenyah    |        5 |
| Paul Laurence Dunbar        |        5 |
| Stephen Leacock             |        5 |
| Achmed Abdullah             |        4 |
| Aldous Huxley               |        4 |
| Banjo Paterson              |        4 |
| Beatrix Potter              |        4 |
| Clara Dillingham Pierson    |        4 |
| Richard Harding Davis       |        4 |
| Richmal Crompton            |        4 |
| Virginia Woolf              |        4 |
| F Scott Fitzgerald          |        3 |
| Gk Chesterton               |        3 |
| Henry Cuyler Bunner         |        3 |
| James Fenimore Cooper       |        3 |
| Leonid Andreyev             |        3 |
| Machado De Assis            |        3 |
| Robert Louis Stevenson      |        3 |
| Sir Arthur Conan Doyle      |        3 |
| Thomas Bailey Aldrich       |        3 |
| William Makepeace Thackeray |        3 |
| Albert F Blaisdell          |        2 |
| Alexander Kielland          |        2 |
| Anzia Yezierska             |        2 |
| Charles W Chesnutt          |        2 |
| Dorothy Parker              |        2 |
| Edward Payson Roe           |        2 |
| Fredric Brown               |        2 |
| Fyodor Dostoevsky           |        2 |
| Gertrude Atherton           |        2 |
| Grace Macgowan Cooke        |        2 |
| Kate Dickinson Sweetser     |        2 |
| Kenneth Grahame             |        2 |
| Kurt Vonnegut Jr            |        2 |
| Mary Hallock Foote          |        2 |
| Nikolai Vasilievich Gogol   |        2 |
| Peter Christen Asbjornsen   |        2 |
| Prosper Merimee             |        2 |
| Ray Bradbury                |        2 |
| Vsevolod Garshin            |        2 |
| Alexandre Dumas             |        1 |
| Amelia B Edwards            |        1 |
| Anne Hollingsworth Wharton  |        1 |
| Arabian Nights              |        1 |
| Booth Tarkington            |        1 |
| Carl Sandburg               |        1 |
| Daniel Defoe                |        1 |
| Dylan Thomas                |        1 |
| E Nesbit                    |        1 |
| Eb White                    |        1 |
| Edward Bellamy              |        1 |
| Edward Stratemeyer          |        1 |
| Ef Benson                   |        1 |
| Elizabeth Stuart Phelps     |        1 |
| Ernest Hemingway            |        1 |
| Evan Hunter                 |        1 |
| Fitz James Obrien           |        1 |
| Giovanni Boccaccio          |        1 |
| Gustave Flaubert            |        1 |
| Guy Wetmore Carryl          |        1 |
| Harold M Sherman            |        1 |
| Ivan Bunin                  |        1 |
| Ivan S Turgenev             |        1 |
| James Baldwin               |        1 |
| James Madison               |        1 |
| James Okeefe                |        1 |
| James Whitcomb Riley        |        1 |
| Jonathan Swift              |        1 |
| Julius Long                 |        1 |
| Kate Douglas Wiggin         |        1 |
| Katherine Rickford          |        1 |
| Lafcadio Hearn              |        1 |
| Marcel Prevost              |        1 |
| Margery Williams            |        1 |
| Mary Shelley                |        1 |
| Ring Lardner                |        1 |
| Robert W Chambers           |        1 |
| Ruth Mcenery Stuart         |        1 |
| St Semyonov                 |        1 |
| Stacy Aumonier              |        1 |
| Thomas Nelson Page          |        1 |
| Tobias Wolff                |        1 |
| Ts Eliot                    |        1 |
| Victor Hugo                 |        1 |
| W F Harvey                  |        1 |
| Wilkie Collins              |        1 |
| William Darcy Haley         |        1 |
| William Faulkner            |        1 |
| William James Lampton       |        1 |
| **Total**                   | **2045** |

Second, the IQR-filtered short stories were balanced by author using a maximum contribution threshold. Authors with 13 or fewer eligible short stories were retained in full, while authors with more than 13 eligible short stories were randomly downsampled to 13 ([Table 3](#table-3)). This capped author-stratified design reduced the risk that prolific authors would dominate the corpus and treated authorial style as a potential source of clustering. The cap was selected as a calibrated design parameter to produce an analytical corpus of 1013 short stories while maintaining broad author coverage. Sensitivity checks showed that a cap of 12 yielded 972 short stories, whereas a cap of 20 yielded 1242 short stories; the selected threshold therefore represented a practical compromise between corpus size, feasibility, and authorial balance. The resulting corpus should be understood as a controlled analytical sample rather than a proportionally representative sample of the original source corpus.

<a id="table-3"></a>

**Table 3. Authors and sampled number of short stories**

| Author                      |    Count |
|-----------------------------|---------:|
| Ambrose Bierce              |       13 |
| Arnold Bennett              |       13 |
| Arthur Quiller Couch        |       13 |
| Bret Harte                  |       13 |
| Charles Dickens             |       13 |
| Charlotte M Yonge           |       13 |
| Edgar Allan Poe             |       13 |
| Edna Ferber                 |       13 |
| Guy De Maupassant           |       13 |
| H P Lovecraft               |       13 |
| Hans Christian Andersen     |       13 |
| Harriet Beecher Stowe       |       13 |
| Henry Lawson                |       13 |
| Henry Van Dyke              |       13 |
| Hg Wells                    |       13 |
| Hh Munro Saki               |       13 |
| Honore De Balzac            |       13 |
| Jack London                 |       13 |
| Jerome K Jerome             |       13 |
| Joseph Sheridan Le Fanu     |       13 |
| Kate Chopin                 |       13 |
| Katherine Mansfield         |       13 |
| L Frank Baum                |       13 |
| Leo Tolstoy                 |       13 |
| Louisa May Alcott           |       13 |
| Lucy Maud Montgomery        |       13 |
| Mark Twain                  |       13 |
| Mary E Wilkins Freeman      |       13 |
| Melville Davisson Post      |       13 |
| Nathaniel Hawthorne         |       13 |
| O Henry                     |       13 |
| P G Wodehouse               |       13 |
| Rabindranath Tagore         |       13 |
| Ralph Henry Barbour         |       13 |
| Robert Barr                 |       13 |
| Rudyard Kipling             |       13 |
| Ts Arthur                   |       13 |
| W W Jacobs                  |       13 |
| Washington Irving           |       13 |
| Wc Morrow                   |       13 |
| William Dean Howells        |       13 |
| Aleksandr I Kuprin          |       12 |
| Algernon Blackwood          |       12 |
| Herman Melville             |       12 |
| James Joyce                 |       12 |
| Stewart Edward White        |       12 |
| Ellis Parker Butler         |       11 |
| Stephen Crane               |       11 |
| Elia W Peattie              |       10 |
| Mary Roberts Rinehart       |       10 |
| Richard Connell             |       10 |
| William Butler Yeats        |       10 |
| Zane Grey                   |       10 |
| Andy Adams                  |        9 |
| Mr James                    |        9 |
| Rex Ellingwood Beach        |        9 |
| Sherwood Anderson           |        9 |
| Susan Glaspell              |        9 |
| Bram Stoker                 |        8 |
| D H Lawrence                |        8 |
| Edith Wharton               |        8 |
| Frank Stockton              |        8 |
| Maxim Gorky                 |        8 |
| Willa Cather                |        8 |
| Frank Norris                |        7 |
| George Gissing              |        7 |
| Harriet Prescott Spofford   |        7 |
| Oscar Wilde                 |        7 |
| Sarah Orne Jewett           |        7 |
| Walter Mcroberts            |        7 |
| Alexsander Pushkin          |        6 |
| Alice Dunbar Nelson         |        6 |
| Laura E Richards            |        6 |
| Philip K Dick               |        6 |
| Chimamanda Ngozi Adichie    |        5 |
| Ethel M Dell                |        5 |
| Franz Kafka                 |        5 |
| George Saunders             |        5 |
| Jhumpa Lahiri               |        5 |
| Nana Kwame Adjei-Brenyah    |        5 |
| Paul Laurence Dunbar        |        5 |
| Stephen Leacock             |        5 |
| Achmed Abdullah             |        4 |
| Aldous Huxley               |        4 |
| Banjo Paterson              |        4 |
| Beatrix Potter              |        4 |
| Clara Dillingham Pierson    |        4 |
| Richard Harding Davis       |        4 |
| Richmal Crompton            |        4 |
| Virginia Woolf              |        4 |
| F Scott Fitzgerald          |        3 |
| Gk Chesterton               |        3 |
| Henry Cuyler Bunner         |        3 |
| James Fenimore Cooper       |        3 |
| Leonid Andreyev             |        3 |
| Machado De Assis            |        3 |
| Robert Louis Stevenson      |        3 |
| Sir Arthur Conan Doyle      |        3 |
| Thomas Bailey Aldrich       |        3 |
| William Makepeace Thackeray |        3 |
| Albert F Blaisdell          |        2 |
| Alexander Kielland          |        2 |
| Anzia Yezierska             |        2 |
| Charles W Chesnutt          |        2 |
| Dorothy Parker              |        2 |
| Edward Payson Roe           |        2 |
| Fredric Brown               |        2 |
| Fyodor Dostoevsky           |        2 |
| Gertrude Atherton           |        2 |
| Grace Macgowan Cooke        |        2 |
| Kate Dickinson Sweetser     |        2 |
| Kenneth Grahame             |        2 |
| Kurt Vonnegut Jr            |        2 |
| Mary Hallock Foote          |        2 |
| Nikolai Vasilievich Gogol   |        2 |
| Peter Christen Asbjornsen   |        2 |
| Prosper Merimee             |        2 |
| Ray Bradbury                |        2 |
| Vsevolod Garshin            |        2 |
| Alexandre Dumas             |        1 |
| Amelia B Edwards            |        1 |
| Anne Hollingsworth Wharton  |        1 |
| Arabian Nights              |        1 |
| Booth Tarkington            |        1 |
| Carl Sandburg               |        1 |
| Daniel Defoe                |        1 |
| Dylan Thomas                |        1 |
| E Nesbit                    |        1 |
| Eb White                    |        1 |
| Edward Bellamy              |        1 |
| Edward Stratemeyer          |        1 |
| Ef Benson                   |        1 |
| Elizabeth Stuart Phelps     |        1 |
| Ernest Hemingway            |        1 |
| Evan Hunter                 |        1 |
| Fitz James Obrien           |        1 |
| Giovanni Boccaccio          |        1 |
| Gustave Flaubert            |        1 |
| Guy Wetmore Carryl          |        1 |
| Harold M Sherman            |        1 |
| Ivan Bunin                  |        1 |
| Ivan S Turgenev             |        1 |
| James Baldwin               |        1 |
| James Madison               |        1 |
| James Okeefe                |        1 |
| James Whitcomb Riley        |        1 |
| Jonathan Swift              |        1 |
| Julius Long                 |        1 |
| Kate Douglas Wiggin         |        1 |
| Katherine Rickford          |        1 |
| Lafcadio Hearn              |        1 |
| Marcel Prevost              |        1 |
| Margery Williams            |        1 |
| Mary Shelley                |        1 |
| Ring Lardner                |        1 |
| Robert W Chambers           |        1 |
| Ruth Mcenery Stuart         |        1 |
| St Semyonov                 |        1 |
| Stacy Aumonier              |        1 |
| Thomas Nelson Page          |        1 |
| Tobias Wolff                |        1 |
| Ts Eliot                    |        1 |
| Victor Hugo                 |        1 |
| W F Harvey                  |        1 |
| Wilkie Collins              |        1 |
| William Darcy Haley         |        1 |
| William Faulkner            |        1 |
| William James Lampton       |        1 |
| **Total**                   | **1013** |
