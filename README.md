
# Phalcon Tuning

```sql

CREATE TABLE test.comments (
  id INTEGER, 
  user_id INTEGER, 
  text TEXT
);

CREATE TABLE test.users (
  id INTEGER, 
  nickname TEXT
);

```

```php

<?php   // TestController.php

namespace App\Controllers;

class TestController extends \Phalcon\Mvc\Controller
{
    /**
     * Example with PHQL
     * @Route("/test1")
     */
    public function test1Action()
    {
        $sql = 'SELECT Comments.*, Users.*
            FROM App\Models\Test\Comments AS Comments
            INNER JOIN App\Models\Test\Users AS Users ON Users.id = Comments.user_id';

        $rows = $this->modelsManager->createQuery($sql)->execute();
        
        /*
         * Standard mode:
         * Executed query count: 1 + (found rows)
         *    (if reusable option is true at Comments.php initialize then little less,
         *     http://bit.ly/1Ghxa2A)
         */
        foreach ($rows as $row) {
            $row->Comments->getUserNickName();
        }

        /*
         * Tuning mode:
         * Executed query count: 1
         */
        foreach ($rows as $row) {
            $this->modelsManager->setReusableRecords2($row->Comments, 'User', $row->Users);

            $row->Comments->getUserNickName();
        }
    }
    
    /**
     * Example with QueryBuilder
     * @Route("/test2")
     */
    public function test2Action()
    {
      $rows = $this->modelsManager->createBuilder()
            ->columns('Comments.*, Users.*')
            ->from(['Comments' => 'App\Models\Test\Comments'])
            ->join('App\Models\Test\Users', 'Users.id = Comments.user_id', 'Users')
            ->getQuery()
            ->execute();
      /*
       * Executed query count: 1
       */
      foreach ($rows as $row) {
          $this->modelsManager->setReusableRecords2($row->Comments, 'User', $row->Users);

          $row->Comments->getUserNickName();
      }
    }
}

```

```php

<?php   // Users.php

namespace App\Models\Test;

class Users extends \Phalcon\Mvc\Model
{
    public function initialize()
    {
        $this->setSchema('test');

        $this->setSource('users');
    }
}

```

```php

<?php   // Comments.php

namespace App\Models\Test;

class Comments extends \Phalcon\Mvc\Model
{
    public function initialize()
    {
        $this->setSchema('test');

        $this->setSource('comments');

        $this->belongsTo('user_id', 'App\Models\Test\Users', 'id', [
            'alias'    => 'User',
            'reusable' => true,
        ]);
    }

    public function getUserNickName()
    {
        return $this->User->nickname;
    }
}

```
