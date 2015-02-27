
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

TestController.php:

```php

<?php

namespace App\Controllers;

/**
 * Class TestController
 *
 * @package App\Controllers
 */
class TestController extends \Phalcon\Mvc\Controller
{
    /**
     * @Route("/test")
     */
    public function indexAction()
    {
        $sql = 'SELECT Comments.*, Users.*
            FROM App\Models\Test\Comments AS Comments
            INNER JOIN App\Models\Test\Users AS Users ON Users.id = Comments.user_id';

        $query = $this->modelsManager->createQuery($sql);
        $rows = $query->execute();
        
        /*
         * Executed 1 + (total rows)
         *    (if reusable option is true at Comments.php initialize then little less)
         */
        foreach ($rows as $row) {
            $row->Comments->getUserNickName();
        }

        // Executed 1 query
        foreach ($rows as $row) {
            $this->modelsManager->setReusableRecords2($row->Comments, 'User', $row->Users);

            $row->Comments->getUserNickName();
        }
    }
}

```

Users.php:

```php

<?php

namespace App\Models\Test;

/**
 * Class Users
 *
 * @property $id;
 * @property $nickname;
 * @package App\Test\Models
 */
class Users extends \Phalcon\Mvc\Model
{
    /**
     * @return string
     */
    public function getSchema()
    {
        return 'test';
    }

    /**
     * @return string
     */
    public function getSource()
    {
        return 'users';
    }
}

```

Comments.php:

```php

<?php

namespace App\Models\Test;

/**
 * Class Comments
 *
 * @property Users               $User
 * @package App\Test\Models
 */
class Comments extends \Phalcon\Mvc\Model
{
    /**
     * @return string
     */
    public function getSchema()
    {
        return 'test';
    }

    /**
     * @return string
     */
    public function getSource()
    {
        return 'comments';
    }

    public function initialize()
    {
        $this->belongsTo('user_id', 'App\Models\Test\Users', 'id', [
            'alias'    => 'User',
            'reusable' => true,
        ]);
    }

    /**
     * @return mixed
     */
    public function getUserNickName()
    {
        return $this->User->nickname;
    }
}

```
